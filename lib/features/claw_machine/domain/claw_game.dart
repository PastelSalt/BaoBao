import 'dart:math';

/// A prize sitting in the machine. Positions are fractions of the play-area width.
class Prize {
  Prize({required this.x, required this.value, required this.rare, this.width = defaultWidth});

  static const defaultWidth = 0.16;

  /// Horizontal centre, from 0 (left edge) to 1 (right edge).
  final double x;
  final double width;

  /// Base payout in ✷ before any combo multiplier.
  final int value;
  final bool rare;
  bool taken = false;
}

/// The outcome of one drop.
class ClawResult {
  const ClawResult({required this.prize, required this.multiplier, required this.streak});

  const ClawResult.miss() : prize = null, multiplier = 1, streak = 0;

  /// The prize caught, or null for a miss.
  final Prize? prize;
  final double multiplier;

  /// Wins in a row including this one. Zero on a miss.
  final int streak;

  bool get won => prize != null;
  bool get rare => prize?.rare ?? false;
  int get payout => prize == null ? 0 : (prize!.value * multiplier).floor();
}

enum ClawPhase {
  /// Waiting for the player.
  idle,

  /// The claw is sweeping side to side.
  moving,

  /// The claw is going down.
  dropping,

  /// The claw is coming back up, with or without a prize.
  lifting,

  /// The claw is carrying a prize to the chute.
  returning,

  /// The prize is falling into the chute.
  releasing,

  /// The round is over; [ClawGame.result] is set. Call [ClawGame.nextRound].
  finished,
}

/// The claw machine's rules and motion, independent of any rendering.
///
/// Drive it by calling [tick] with elapsed time. All positions are fractions:
/// [clawX] across the play area, [depth] from 0 (top) to 1 (prize level).
class ClawGame {
  ClawGame({Random? random, List<Prize>? prizes}) : _random = random ?? Random() {
    this.prizes = prizes ?? generatePrizes(_random);
  }

  static const prizeCount = 4;
  static const rareChance = 0.15;

  /// The claw catches a prize when its centre is within `width / catchTolerance`
  /// of the prize's centre. Deliberately forgiving: this is a comfort game.
  static const catchTolerance = 1.3;

  /// Sweep speed in play-area widths per second.
  static const sweepSpeed = 0.9;
  static const minX = 0.08;
  static const maxX = 0.92;

  /// Where prizes are dropped off.
  static const chuteX = minX;

  static const dropDuration = Duration(milliseconds: 1000);
  static const liftDuration = Duration(milliseconds: 1200);
  static const returnDuration = Duration(milliseconds: 900);
  static const releaseDuration = Duration(milliseconds: 500);

  final Random _random;
  late List<Prize> prizes;

  ClawPhase phase = ClawPhase.idle;
  double clawX = 0.5;
  double depth = 0;

  /// 0 to 1 progress of the prize falling into the chute.
  double releaseProgress = 0;
  int _direction = 1;
  double _returnFromX = 0;
  Duration _phaseElapsed = Duration.zero;

  /// Wins in a row so far.
  int streak = 0;

  /// The prize currently in the claw, if any.
  Prize? held;

  /// Set once the catch is decided (at the bottom of the drop).
  ClawResult? result;

  static double multiplierFor(int streak) => switch (streak) {
    <= 2 => 1.0,
    <= 4 => 1.2,
    <= 6 => 1.5,
    _ => 2.0,
  };

  static List<Prize> generatePrizes(Random random) {
    const span = maxX - minX;
    const slot = span / prizeCount;
    return [
      for (var i = 0; i < prizeCount; i++)
        () {
          final rare = random.nextDouble() < rareChance;
          final jitter = (random.nextDouble() - 0.5) * (slot - Prize.defaultWidth);
          return Prize(
            x: minX + slot * (i + 0.5) + jitter,
            value: rare ? 150 + random.nextInt(101) : 10 + random.nextInt(91),
            rare: rare,
          );
        }(),
    ];
  }

  /// Starts the claw sweeping. Does nothing unless [phase] is idle.
  void startMoving() {
    if (phase != ClawPhase.idle) return;
    phase = ClawPhase.moving;
  }

  /// Drops the claw where it is. Does nothing unless it is sweeping.
  void drop() {
    if (phase != ClawPhase.moving) return;
    _enter(ClawPhase.dropping);
  }

  /// Advances the simulation by [dt].
  void tick(Duration dt) {
    final seconds = dt.inMicroseconds / Duration.microsecondsPerSecond;
    switch (phase) {
      case ClawPhase.idle || ClawPhase.finished:
        return;
      case ClawPhase.moving:
        _sweep(seconds);
      case ClawPhase.dropping:
        depth = _advance(dt, dropDuration);
        if (depth >= 1) {
          _decideCatch();
          _enter(ClawPhase.lifting);
        }
      case ClawPhase.lifting:
        depth = 1 - _advance(dt, liftDuration);
        if (depth <= 0) {
          if (held == null) {
            phase = ClawPhase.finished;
          } else {
            _returnFromX = clawX;
            _enter(ClawPhase.returning);
          }
        }
      case ClawPhase.returning:
        final t = _advance(dt, returnDuration);
        clawX = _returnFromX + (chuteX - _returnFromX) * t;
        if (t >= 1) _enter(ClawPhase.releasing);
      case ClawPhase.releasing:
        releaseProgress = _advance(dt, releaseDuration);
        if (releaseProgress >= 1) {
          held = null;
          phase = ClawPhase.finished;
        }
    }
  }

  /// Resets the claw for another go. Refills the machine once it is empty.
  void nextRound() {
    if (phase != ClawPhase.finished) return;
    phase = ClawPhase.idle;
    clawX = 0.5;
    depth = 0;
    releaseProgress = 0;
    _direction = 1;
    result = null;
    held = null;
    if (prizes.every((prize) => prize.taken)) prizes = generatePrizes(_random);
  }

  /// The prize the claw would catch if dropped at [x], if any.
  Prize? prizeAt(double x) {
    Prize? best;
    var bestDistance = double.infinity;
    for (final prize in prizes) {
      if (prize.taken) continue;
      final distance = (x - prize.x).abs();
      if (distance < prize.width / catchTolerance && distance < bestDistance) {
        best = prize;
        bestDistance = distance;
      }
    }
    return best;
  }

  void _sweep(double seconds) {
    clawX += _direction * sweepSpeed * seconds;
    // Reflect off the walls, however large the step.
    while (clawX > maxX || clawX < minX) {
      if (clawX > maxX) {
        clawX = 2 * maxX - clawX;
        _direction = -1;
      } else {
        clawX = 2 * minX - clawX;
        _direction = 1;
      }
    }
  }

  void _decideCatch() {
    final prize = prizeAt(clawX);
    if (prize == null) {
      streak = 0;
      result = const ClawResult.miss();
      return;
    }
    prize.taken = true;
    held = prize;
    streak += 1;
    result = ClawResult(prize: prize, multiplier: multiplierFor(streak), streak: streak);
  }

  void _enter(ClawPhase next) {
    phase = next;
    _phaseElapsed = Duration.zero;
  }

  /// Adds [dt] to the phase timer and returns progress from 0 to 1.
  double _advance(Duration dt, Duration total) {
    _phaseElapsed += dt;
    return (_phaseElapsed.inMicroseconds / total.inMicroseconds).clamp(0.0, 1.0);
  }
}
