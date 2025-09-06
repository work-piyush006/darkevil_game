// lib/main.dart
// DarkEvil — Single file game (Flutter + Flame) ready to upload
// Made by DaRkEviL Developers 🗡️
//
// pubspec.yaml me ensure karna:
// dependencies:
//   flutter:
//     sdk: flutter
//   flame: ^1.13.1
// assets:
//   - assets/hero.png
//   - assets/enemies.png
//   - assets/boss.png
//   - assets/bg.png
//   - assets/intro_scene.png
//   - assets/logo.png

import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DarkEvilApp());
}

class DarkEvilApp extends StatelessWidget {
  const DarkEvilApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '⚔ DarkEvil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: false),
      home: const SplashScreen(),
      routes: {
        '/intro': (_) => const IntroScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/levels': (_) => const LevelSelectScreen(),
      },
    );
  }
}

/* ============================= Splash ============================= */

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController c;
  late final Animation<double> fade;
  @override
  void initState() {
    super.initState();
    c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    fade = CurvedAnimation(parent: c, curve: Curves.easeIn);
    Timer(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/intro');
    });
  }
  @override
  void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: fade,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/logo.png', width: 140, height: 140,
              errorBuilder: (_, __, ___) => const Icon(Icons.sports_martial_arts, size: 120, color: Colors.redAccent)),
            const SizedBox(height: 12),
            const Text('DarkEvil', style: TextStyle(fontSize: 28, color: Colors.redAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Made by DaRkEviL Developers', style: TextStyle(color: Colors.white70)),
          ]),
        ),
      ),
    );
  }
}

/* ============================= Intro (animated story) ============================= */

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}
class _IntroScreenState extends State<IntroScreen> {
  final List<String> lines = [
    'Shehar par andhera cha gaya...',
    '72 levels, 6 chapters — har 12ve level par boss.',
    'Chapter 6: Captain Shadow aur Dark King — SMARTER THAN AI.',
    'Tayyar ho?'
  ];
  int i = 0;
  @override
  void initState() {
    super.initState();
    _auto();
  }
  Future<void> _auto() async {
    for (int k = 0; k < lines.length - 1; k++) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() => i++);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/intro_scene.png', fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.black)),
        Container(color: Colors.black54),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Padding(
              key: ValueKey(i),
              padding: const EdgeInsets.all(24),
              child: Text(
                lines[i],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, height: 1.4),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 28, right: 20,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text('Continue'),
          ),
        )
      ]),
    );
  }
}

/* ============================= Login ============================= */

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final name = TextEditingController();
  double age = 18;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Player Details', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              TextField(
                controller: name,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name', labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                ),
              ),
              const SizedBox(height: 12),
              Text('Age: ${age.toInt()}', style: const TextStyle(color: Colors.white70)),
              Slider(value: age, min: 8, max: 70, divisions: 62, onChanged: (v) => setState(() => age = v)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (name.text.trim().isEmpty) return;
                  PlayerProfile.name = name.text.trim();
                  PlayerProfile.age = age.toInt();
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text('Continue'),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

class PlayerProfile {
  static String name = 'Player';
  static int age = 18;
}

/* ============================= Progress / Economy ============================= */

class GameProgress {
  static int unlockedLevel = 1;
  static int coins = 0;

  static int chapterOf(int level) => ((level - 1) ~/ 12) + 1;
  static bool isBoss(int level) => level % 12 == 0;
  static String bossName(int level) {
    if (level == 71) return 'Captain Shadow';
    if (level == 72) return 'Dark King';
    final c = chapterOf(level);
    const pool = ['Warg Chief','Blood Mage','Grim Wolf','Night Bat','Void Golem'];
    return pool[(c - 1).clamp(0, pool.length - 1)];
    }

  static int rewardFor(int level) {
    final base = 30 + (chapterOf(level) - 1) * 10;
    return isBoss(level) ? base + 120 : base;
  }

  static void completeLevel(int level) {
    coins += rewardFor(level);
    if (level == unlockedLevel && unlockedLevel < 72) unlockedLevel++;
  }
}

/* ============================= Home ============================= */

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final hello = 'Welcome, ${PlayerProfile.name} (Age ${PlayerProfile.age})';
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('DarkEvil'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, '/levels'), icon: const Icon(Icons.grid_view)),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoreScreen(initialCoins: GameProgress.coins))),
            icon: const Icon(Icons.store),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(hello, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Coins: ${GameProgress.coins}', style: const TextStyle(color: Colors.yellow, fontSize: 16)),
            const SizedBox(height: 22),
            ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start • Chapter 1 • Level 1'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GamePage(level: 1)))),
            const SizedBox(height: 10),
            ElevatedButton.icon(icon: const Icon(Icons.grid_view), label: const Text('Level Select'), onPressed: () => Navigator.pushNamed(context, '/levels')),
            const SizedBox(height: 10),
            ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false)),
          ]),
        ),
      ),
    );
  }
}

/* ============================= Level Select ============================= */

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Select Level')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.1),
        itemCount: 72,
        itemBuilder: (_, i) {
          final level = i + 1;
          final unlocked = level <= GameProgress.unlockedLevel;
          final ch = GameProgress.chapterOf(level);
          final boss = GameProgress.isBoss(level);
          return ElevatedButton(
            onPressed: unlocked ? () => Navigator.push(_, MaterialPageRoute(builder: (__) => GamePage(level: level))) : null,
            style: ElevatedButton.styleFrom(backgroundColor: unlocked ? (boss ? Colors.deepPurple : Colors.redAccent) : Colors.grey.shade700),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('L$level', style: const TextStyle(fontSize: 16)),
              Text('Ch $ch', style: const TextStyle(fontSize: 12, color: Colors.white70)),
              if (boss) const Text('BOSS', style: TextStyle(fontSize: 11, color: Colors.amber)),
            ]),
          );
        },
      ),
    );
  }
}

/* ============================= Store ============================= */

class StoreScreen extends StatefulWidget {
  final int initialCoins;
  const StoreScreen({super.key, required this.initialCoins});
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}
class _StoreScreenState extends State<StoreScreen> {
  late int coins;
  int sword = 1;
  int armor = 0;
  bool doubleJump = false;
  bool ultimateUnlocked = false;
  @override
  void initState() { super.initState(); coins = widget.initialCoins; }
  void buy(String name, int cost, VoidCallback apply) {
    if (coins >= cost) {
      setState(() {
        coins -= cost;
        apply();
        GameProgress.coins = coins;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name purchased! Coins: $coins')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough coins!')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Store')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(children: [
            const SizedBox(height: 16),
            Text('Coins: $coins', style: const TextStyle(color: Colors.yellow, fontSize: 18)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _item('Sword +1', 80, () => sword++),
              _item('Armor +1', 90, () => armor++),
              _item('Health +40', 60, () {}),
              _item('Shuriken ×5', 50, () {}),
              _item('Double Jump', 150, () => doubleJump = true),
              _item('Unlock Ultimate', 220, () => ultimateUnlocked = true),
            ]),
            const SizedBox(height: 12),
            const Text('Upgrades apply in next game session.', style: TextStyle(color: Colors.white70)),
          ]),
        ),
      ),
    );
  }
  Widget _item(String name, int cost, VoidCallback apply) =>
      ElevatedButton(onPressed: () => buy(name, cost, apply), child: Text('$name • $cost'));
}

/* ============================= Game Screen ============================= */

class GamePage extends StatefulWidget {
  final int level;
  const GamePage({super.key, required this.level});
  @override
  State<GamePage> createState() => _GamePageState();
}
class _GamePageState extends State<GamePage> {
  late final DarkEvilEngine game;
  @override
  void initState() { super.initState(); game = DarkEvilEngine(level: widget.level); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<DarkEvilEngine>(
        game: game,
        overlayBuilderMap: {
          HudOverlay.id: (_, g) => HudOverlay(game: g),
          ControlsOverlay.id: (_, g) => ControlsOverlay(game: g),
          PauseOverlay.id: (_, g) => PauseOverlay(game: g),
          StoreOverlay.id: (_, g) => StoreOverlay(game: g),
          DialogueOverlay.id: (_, g) => DialogueOverlay(game: g),
          LevelCompleteOverlay.id: (_, g) => LevelCompleteOverlay(game: g),
          GameOverOverlay.id: (_, g) => GameOverOverlay(game: g),
        },
        initialActiveOverlays: const {HudOverlay.id, ControlsOverlay.id},
        loadingBuilder: (_) => const ColoredBox(color: Colors.black, child: Center(child: CircularProgressIndicator())),
      ),
    );
  }
}

/* ============================= Flame Engine ============================= */

class DarkEvilEngine extends FlameGame with HasKeyboardHandlerComponents {
  final int level;
  DarkEvilEngine({required this.level});

  late Sprite bg;
  late HeroDude hero;
  final List<Enemy> enemies = [];
  int coins = 0;
  bool levelComplete = false;

  int chapter = 1;
  int difficulty = 1;
  Rect worldBounds = const Rect.fromLTWH(0, 0, 6400, 720);

  @override
  Color backgroundColor() => const Color(0xFF090C12);

  @override
  Future<void> onLoad() async {
    await images.loadAll(['hero.png', 'enemies.png', 'boss.png', 'bg.png', 'intro_scene.png', 'logo.png']);
    chapter = GameProgress.chapterOf(level);
    difficulty = [1, 1, 2, 3, 4, 6, 10][chapter]; // ch6 = 10 (hard)
    bg = Sprite(images.fromCache('bg.png'));

    camera.viewport = FixedResolutionViewport(Vector2(1280, 720));
    camera.worldBounds = worldBounds;

    add(BackgroundTiled(bg: bg, width: worldBounds.width));
    add(Ground(size: Vector2(worldBounds.width, 140)));

    hero = HeroDude(position: Vector2(220, 720 - 180));
    add(hero);
    camera.followComponent(hero, worldBounds: camera.worldBounds);

    _spawnWave();
  }

  void _spawnWave() {
    enemies.clear();
    final rnd = Random(level * 97);
    int mobCount = 5 + (chapter - 1) * 2 + (level % 12);
    for (int i = 0; i < mobCount; i++) {
      final x = 720 + i * 280 + rnd.nextInt(160);
      final kind = (i % 3 == 0) ? EnemyKind.mage : EnemyKind.grunt;
      final e = Enemy.basic(
        kind: kind,
        position: Vector2(x.toDouble(), 720 - 180),
        target: () => hero.position,
        scaleDiff: difficulty,
      );
      enemies.add(e);
      add(e);
    }

    if (GameProgress.isBoss(level)) {
      final bx = worldBounds.width - 720;
      final boss = Enemy.boss(
        name: level == 71 ? 'Captain Shadow' : 'Dark King',
        position: Vector2(bx, 720 - 220),
        target: () => hero.position,
        scaleDiff: difficulty,
        smarter: true,
        onPhase: () => showDialogue('⚡ Rage unleashed!'),
        onDefeated: () => completeLevel(),
      );
      enemies.add(boss);
      add(boss);
    }
  }

  void showPause() => overlays.add(PauseOverlay.id);
  void hidePause() => overlays.remove(PauseOverlay.id);
  void showStore() => overlays.add(StoreOverlay.id);
  void hideStore() => overlays.remove(StoreOverlay.id);

  void showDialogue(String t) { DialogueOverlay.text = t; overlays.add(DialogueOverlay.id); }
  void hideDialogue() => overlays.remove(DialogueOverlay.id);

  void completeLevel() {
    if (levelComplete) return;
    levelComplete = true;
    final reward = GameProgress.rewardFor(level);
    coins += reward;
    GameProgress.coins += reward;
    GameProgress.completeLevel(level);
    overlays.add(LevelCompleteOverlay.id);
  }

  void gameOver() => overlays.add(GameOverOverlay.id);

  void onControls({
    required bool left,
    required bool right,
    required bool runHeld,
    required bool jumpTap,
    required bool attack,
    required bool shuriken,
    required bool magic,
    required bool ultimate,
  }) {
    hero.inputLeft = left;
    hero.inputRight = right;
    hero.inputRunHeld = runHeld;
    if (jumpTap) hero.onJumpTap();
    if (attack) hero.doSword();
    if (shuriken) hero.throwShuriken();
    if (magic) hero.castMagic();

    // Final level special: Captain Shadow soul aid
    if (ultimate && level == 72 && !hero.usedUltimate) {
      hero.usedUltimate = true;
      showDialogue('Captain Shadow ki soul tumhari talwar ko empower karti hai!');
      for (final b in enemies.where((e) => e.kind == EnemyKind.boss)) {
        b.health = max(1, (b.health * 0.7).floor());
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!levelComplete &&
        hero.position.x > worldBounds.width - 240 &&
        enemies.where((e) => e.kind != EnemyKind.boss && e.alive).isEmpty) {
      completeLevel();
    }
    if (hero.dead) gameOver();
  }
}

/* ============================= World Decor ============================= */

class BackgroundTiled extends PositionComponent {
  final Sprite bg;
  final double width;
  BackgroundTiled({required this.bg, required this.width}) {
    priority = -1000;
    size = Vector2(width, 720);
    position = Vector2.zero();
  }
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    const tileW = 1280.0;
    for (double x = 0; x < width; x += tileW) {
      bg.render(canvas, position: Vector2(x, 0), size: const Vector2(tileW, 720));
    }
  }
}

class Ground extends PositionComponent {
  Ground({required Vector2 size}) {
    this.size = size;
    position = Vector2.zero();
    priority = -900;
  }
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = Rect.fromLTWH(0, 720 - 120, size.x, 140);
    canvas.drawRect(rect, Paint()..color = const Color(0xFF111823));
  }
}

/* ============================= Hero ============================= */

class HeroDude extends SpriteComponent with KeyboardHandler, HasGameRef<DarkEvilEngine> {
  bool inputLeft = false, inputRight = false, inputRunHeld = false;
  int health = 100;
  int swordLevel = 1;
  int armorLevel = 0;
  int shurikenCount = 5;
  double vx = 0, vy = 0;
  final gravity = 1600.0;
  bool onGround = false;
  int _tapCount = 0;
  Timer? _tapTimer;
  bool dead = false;
  bool usedUltimate = false;

  HeroDude({required super.position})
      : super(size: Vector2(96, 96), anchor: Anchor.center, priority: 10);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache('hero.png'));
  }

  void onJumpTap() {
    _tapCount++;
    _tapTimer?.cancel();
    _tapTimer = Timer(const Duration(milliseconds: 250), () => _tapCount = 0);
    if (_tapCount == 2) {
      vy = onGround ? -900 : -820; // double jump
      _tapCount = 0;
    } else if (onGround) {
      vy = -760;
    }
  }

  void doSword() {
    final hitbox = Rect.fromLTWH(position.x - 60, position.y - 40, 120, 80);
    for (final e in game.children.whereType<Enemy>()) {
      if (!e.alive) continue;
      final r = Rect.fromLTWH(e.position.x - 30, e.position.y - 40, 60, 80);
      if (r.overlaps(hitbox)) {
        final dmg = 16 + swordLevel * 5;
        e.takeDamage(dmg);
      }
    }
  }

  void throwShuriken() {
    if (shurikenCount <= 0) return;
    shurikenCount--;
    game.add(Shuriken(
      origin: position + Vector2(0, -20),
      dir: Vector2((scale.x >= 0) ? 1 : -1, 0),
      onHit: (e) => e.takeDamage(20),
    ));
  }

  void castMagic() {
    final dir = (scale.x >= 0) ? 1 : -1;
    final area = Rect.fromLTWH(position.x + dir * 30 - 90, position.y - 52, 180, 104);
    for (final e in game.children.whereType<Enemy>()) {
      if (!e.alive) continue;
      final r = Rect.fromLTWH(e.position.x - 28, e.position.y - 42, 56, 84);
      if (r.overlaps(area)) {
        e.takeDamage(26);
      }
    }
  }

  void takeDamage(int dmg) {
    final reduced = max(1, dmg - armorLevel * 3);
    health -= reduced;
    if (health <= 0) {
      health = 0;
      if (!dead) {
        dead = true;
        Future.delayed(const Duration(milliseconds: 250), () => removeFromParent());
      }
    }
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    inputLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA);
    inputRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD);
    inputRunHeld = keysPressed.contains(LogicalKeyboardKey.shiftLeft);
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) onJumpTap();
      if (event.logicalKey == LogicalKeyboardKey.keyJ) doSword();
      if (event.logicalKey == LogicalKeyboardKey.keyK) throwShuriken();
      if (event.logicalKey == LogicalKeyboardKey.keyL) castMagic();
      if (event.logicalKey == LogicalKeyboardKey.keyU) usedUltimate ? null : game.onControls(
        left: inputLeft, right: inputRight, runHeld: inputRunHeld,
        jumpTap: false, attack: false, shuriken: false, magic: false, ultimate: true);
    }
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    double accel = 0;
    if (inputLeft) accel -= 1;
    if (inputRight) accel += 1;
    final sprint = inputRunHeld;
    final maxSpeed = sprint ? 360.0 : 230.0;
    final ax = sprint ? 1600.0 : 1000.0;

    if (accel == 0) {
      if (vx.abs() < 20) {
        vx = 0;
      } else {
        vx += -vx.sign * 1400 * dt;
      }
    } else {
      vx += accel * ax * dt;
      vx = vx.clamp(-maxSpeed, maxSpeed);
      scale.x = accel >= 0 ? 1 : -1;
    }

    vy += gravity * dt;
    position.x += vx * dt;
    position.y += vy * dt;

    if (position.y >= 720 - 120 - size.y / 2) {
      position.y = 720 - 120 - size.y / 2;
      vy = 0;
      onGround = true;
    } else {
      onGround = false;
    }

    position.x = position.x.clamp(0 + size.x / 2, game.worldBounds.width - size.x / 2);
  }
}

/* ============================= Projectile ============================= */

class Shuriken extends SpriteComponent with HasGameRef<DarkEvilEngine> {
  final Vector2 dir;
  final void Function(Enemy) onHit;
  double life = 2.0;
  Shuriken({required Vector2 origin, required this.dir, required this.onHit})
      : super(size: Vector2(28, 28), position: origin, anchor: Anchor.center, priority: 5);
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 10, Paint()..color = Colors.white);
  }
  @override
  void update(double dt) {
    super.update(dt);
    position += dir * 520 * dt;
    life -= dt;
    if (life <= 0) removeFromParent();
    for (final e in game.children.whereType<Enemy>()) {
      if (!e.alive) continue;
      final r = Rect.fromLTWH(e.position.x - 25, e.position.y - 35, 50, 70);
      if (r.contains(Offset(position.x, position.y))) {
        onHit(e);
        removeFromParent();
        break;
      }
    }
  }
}

/* ============================= Enemies & Boss AI ============================= */

enum EnemyKind { grunt, mage, boss }

class Enemy extends SpriteComponent with HasGameRef<DarkEvilEngine> {
  EnemyKind kind;
  int health;
  int attack;
  bool alive = true;
  final Vector2 Function() target;
  double cooldown = 0;
  final int scaleDiff;
  final String name;
  final bool smarter;
  final VoidCallback? onPhase;
  final VoidCallback? onDefeated;
  bool raged = false;

  Enemy._({
    required this.kind,
    required this.health,
    required this.attack,
    required super.position,
    required this.target,
    required this.scaleDiff,
    required this.name,
    required this.smarter,
    this.onPhase,
    this.onDefeated,
  }) : super(size: Vector2(96, 96), anchor: Anchor.center, priority: 8);

  factory Enemy.basic({
    required EnemyKind kind,
    required Vector2 position,
    required Vector2 Function() target,
    required int scaleDiff,
  }) {
    final baseHp = kind == EnemyKind.mage ? 150 : 100;
    final baseAtk = kind == EnemyKind.mage ? 14 : 8;
    return Enemy._(
      kind: kind,
      health: baseHp + 18 * scaleDiff,
      attack: baseAtk + 2 * scaleDiff,
      position: position,
      target: target,
      scaleDiff: scaleDiff,
      name: kind == EnemyKind.mage ? 'Mage' : 'Grunt',
      smarter: false,
    );
  }

  factory Enemy.boss({
    required String name,
    required Vector2 position,
    required Vector2 Function() target,
    required int scaleDiff,
    required bool smarter,
    VoidCallback? onPhase,
    VoidCallback? onDefeated,
  }) {
    return Enemy._(
      kind: EnemyKind.boss,
      health: 680 + 90 * scaleDiff,
      attack: 22 + 4 * scaleDiff,
      position: position,
      target: target,
      scaleDiff: scaleDiff,
      name: name,
      smarter: smarter,
      onPhase: onPhase,
      onDefeated: onDefeated,
    );
  }

  @override
  Future<void> onLoad() async {
    final img = (kind == EnemyKind.boss) ? 'boss.png' : 'enemies.png';
    sprite = Sprite(game.images.fromCache(img));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!alive) return;

    final t = target();
    final dx = t.x - position.x;
    final dist = (t - position).length;
    scale.x = (dx >= 0) ? 1 : -1;

    // ===== Smarter AI (boss only) =====
    if (kind == EnemyKind.boss && smarter) {
      // phase trigger
      if (!raged && health <= (450 + 45 * scaleDiff)) {
        raged = true;
        onPhase?.call();
      }
      // dash / dodge windows
      cooldown -= dt;
      final speed = raged ? 220.0 : 160.0;
      if (dist > 160) {
        position.x += (dx.sign) * speed * dt;
      } else {
        // choose action
        if (cooldown <= 0) {
          final choice = _weighted([
            _W('strike', 0.5),
            _W('dash', 0.25),
            _W('shadowstep', 0.25),
          ]);
          if (choice == 'strike') {
            _strike();
            cooldown = raged ? 0.6 : 0.9;
          } else if (choice == 'dash') {
            position.x += dx.sign * (raged ? 340 : 260);
            _strike();
            cooldown = 1.0;
          } else if (choice == 'shadowstep') {
            // short teleport behind the hero
            position.x = t.x - dx.sign * 90;
            _strike();
            cooldown = 1.2;
          }
        }
      }
    } else {
      // ===== basic AI =====
      if (dist > 140) {
        final speed = (kind == EnemyKind.boss) ? 160.0 : 120.0;
        position.x += dx.sign * speed * dt;
      } else {
        cooldown -= dt;
        if (cooldown <= 0) {
          cooldown = (kind == EnemyKind.boss) ? 0.9 : 1.2;
          game.hero.takeDamage(attack);
        }
      }
    }
  }

  void _strike() {
    game.hero.takeDamage(attack + (raged ? 8 : 0));
    // small chance to dodge player sword if very close (smart)
    if (Random().nextDouble() < (raged ? 0.25 : 0.12)) {
      position.x += (scale.x > 0 ? -1 : 1) * 60;
    }
  }

  void takeDamage(int dmg) {
    if (!alive) return;
    health -= dmg;
    if (health <= 0) {
      alive = false;
      Future.delayed(const Duration(milliseconds: 300), () => removeFromParent());
      if (kind == EnemyKind.boss) {
        game.showDialogue('$name defeated!');
        onDefeated?.call();
      }
    }
  }
}

class _W { final String k; final double w; _W(this.k, this.w); }
String _weighted(List<_W> list) {
  final s = list.fold<double>(0, (p, e) => p + e.w);
  double r = Random().nextDouble() * s;
  for (final e in list) { if ((r -= e.w) <= 0) return e.k; }
  return list.last.k;
}

/* ============================= HUD & Overlays ============================= */

class HudOverlay extends StatelessWidget {
  static const id = 'hud';
  final DarkEvilEngine game;
  const HudOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            _bar('HP', game.hero.health / 100),
            const SizedBox(width: 10),
            Text('💰 ${GameProgress.coins + game.coins}', style: const TextStyle(fontSize: 16, color: Colors.yellow)),
            const SizedBox(width: 10),
            ElevatedButton(onPressed: () => game.showPause(), child: const Text('Pause')),
          ]),
        ),
      ),
    );
  }
  Widget _bar(String t, double p) {
    p = p.clamp(0, 1);
    return Container(
      width: 160, height: 16,
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
      child: Stack(children: [
        FractionallySizedBox(widthFactor: p, child: Container(decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)))),
        Center(child: Text('$t ${(p * 100).toInt()}%', style: const TextStyle(fontSize: 11))),
      ]),
    );
  }
}

class ControlsOverlay extends StatefulWidget {
  static const id = 'controls';
  final DarkEvilEngine game;
  const ControlsOverlay({super.key, required this.game});
  @override
  State<ControlsOverlay> createState() => _ControlsOverlayState();
}
class _ControlsOverlayState extends State<ControlsOverlay> {
  bool left = false, right = false, runHeld = false;
  void tick({bool jump = false, bool atk = false, bool shuriken = false, bool magic = false, bool ultimate = false}) {
    widget.game.onControls(
      left: left, right: right, runHeld: runHeld,
      jumpTap: jump, attack: atk, shuriken: shuriken, magic: magic, ultimate: ultimate,
    );
  }
  @override
  Widget build(BuildContext context) {
    final pad = const EdgeInsets.all(10);
    return Stack(children: [
      Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: pad,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            hold('←', (v) { setState(() => left = v); tick(); }),
            const SizedBox(width: 8),
            hold('→', (v) { setState(() => right = v); tick(); }),
            const SizedBox(width: 8),
            hold('RUN', (v) { setState(() => runHeld = v); tick(); }),
          ]),
        ),
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: pad,
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            tap('JUMP', () => tick(jump: true)),
            tap('⚔', () => tick(atk: true)),
            tap('⭐', () => tick(shuriken: true)),
            tap('🔥', () => tick(magic: true)),
            tap('🥷', () => tick(ultimate: true)),
            tap('🛒', () => widget.game.showStore()),
          ]),
        ),
      ),
    ]);
  }
  Widget tap(String t, VoidCallback onTap) =>
      ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, minimumSize: const Size(64, 48)), child: Text(t));
  Widget hold(String t, void Function(bool) onHold) {
    return Listener(
      onPointerDown: (_) => onHold(true),
      onPointerUp: (_) => onHold(false),
      child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, minimumSize: const Size(64, 48)), child: Text(t)),
    );
  }
}

class PauseOverlay extends StatelessWidget {
  static const id = 'pause';
  final DarkEvilEngine game;
  const PauseOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.black.withOpacity(0.86),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Paused', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: () => game.hidePause(), child: const Text('Resume')),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Exit to Home')),
          ]),
        ),
      ),
    );
  }
}

class StoreOverlay extends StatefulWidget {
  static const id = 'store';
  final DarkEvilEngine game;
  const StoreOverlay({super.key, required this.game});
  @override
  State<StoreOverlay> createState() => _StoreOverlayState();
}
class _StoreOverlayState extends State<StoreOverlay> {
  void buy(String name, int cost, VoidCallback apply) {
    final g = widget.game;
    if (GameProgress.coins + g.coins >= cost) {
      if (g.coins >= cost) {
        g.coins -= cost;
      } else {
        final need = cost - g.coins;
        g.coins = 0;
        GameProgress.coins -= need;
      }
      apply();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name purchased!')));
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough coins!')));
    }
  }
  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    return Center(
      child: Card(
        color: Colors.black.withOpacity(0.92),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Coins: ${GameProgress.coins + g.coins}', style: const TextStyle(fontSize: 18, color: Colors.yellow)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                item('Sword Upgrade', 80, () => g.hero.swordLevel++),
                item('Armor Shield', 90, () => g.hero.armorLevel++),
                item('Health +40', 60, () => g.hero.health = min(100, g.hero.health + 40)),
                item('Shuriken ×5', 50, () => g.hero.shurikenCount += 5),
                item('Unlock Ultimate', 220, () => g.hero.usedUltimate = false),
              ]),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => g.hideStore(), child: const Text('Close')),
            ]),
          ),
        ),
      ),
    );
  }
  Widget item(String name, int cost, VoidCallback apply) =>
      ElevatedButton(onPressed: () => buy(name, cost, apply), child: Text('$name • $cost'));
}

class DialogueOverlay extends StatelessWidget {
  static const id = 'dialogue';
  static String text = '';
  final DarkEvilEngine game;
  const DialogueOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.75), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
          child: Row(children: [
            Expanded(child: Text(text, style: const TextStyle(fontSize: 16, height: 1.3))),
            TextButton(onPressed: () => game.hideDialogue(), child: const Text('OK'))
          ]),
        ),
      ),
    );
  }
}

class LevelCompleteOverlay extends StatelessWidget {
  static const id = 'levelComplete';
  final DarkEvilEngine game;
  const LevelCompleteOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) {
    final reward = GameProgress.rewardFor(game.level);
    final boss = GameProgress.isBoss(game.level);
    final nextLevel = (game.level < 72) ? game.level + 1 : 72;
    return Center(
      child: Card(
        color: Colors.black.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Level Complete!', style: TextStyle(fontSize: 22, color: Colors.greenAccent)),
            const SizedBox(height: 8),
            Text('Reward: $reward coins', style: const TextStyle(color: Colors.yellow)),
            if (boss)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Boss Defeated: ${GameProgress.bossName(game.level)}', style: const TextStyle(color: Colors.amber))),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (game.level < 72) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GamePage(level: nextLevel)));
                } else {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
                }
              },
              child: Text(game.level < 72 ? 'Next Level (L$nextLevel)' : 'Finish'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () { Navigator.pop(context); Navigator.pushNamed(context, '/levels'); },
              child: const Text('Level Select'),
            ),
          ]),
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  static const id = 'gameOver';
  final DarkEvilEngine game;
  const GameOverOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.black.withOpacity(0.92),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('You Died', style: TextStyle(fontSize: 22, color: Colors.redAccent)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => GamePage(level: game.level))); },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () { Navigator.pop(context); Navigator.pushNamed(context, '/levels'); },
              child: const Text('Level Select'),
            ),
          ]),
        ),
      ),
    );
  }
}
