import pygame
import random

class Player:
    def __init__(self, pos):
        self.pos = pos
        self.image = pygame.image.load("player_sprite.png").convert_alpha()
        self.rect = self.image.get_rect()
        self.rect.size = (40, 40)
        self.rect.center = (pos.x, pos.y)


    def update(self, mouse_position):
        keys = pygame.key.get_pressed()
        if keys[pygame.K_w]:
            player.pos.y -= 300 * dt
        if keys[pygame.K_s]:
            player.pos.y += 300 * dt
        if keys[pygame.K_a]:
            player.pos.x -= 300 * dt
        if keys[pygame.K_d]:
            player.pos.x += 300 * dt
        self.rect.center = (self.pos.x, self.pos.y)
        angle = (mouse_position - player.pos).angle_to((1, 0))
        player_rotated = pygame.transform.rotate(player.image, angle - 90)
        player_rotated_rect = player_rotated.get_rect(center=player.pos)
        screen.blit(player_rotated, player_rotated_rect)
        pygame.draw.rect(screen, "blue", player.rect)

    def shoot(self, mouse_position):
        keys = pygame.key.get_pressed()
        global cooldown_tracker
        global cooldown
        cooldown_tracker += clock.get_time()
        if cooldown_tracker > cooldown:
            cooldown_tracker = 0

        if keys[pygame.K_SPACE] and cooldown_tracker == 0:
            b_pos = self.pos + (mouse_position - self.pos).normalize() * 20
            bullets.append(Bullet(b_pos, (mouse_position - self.pos).normalize()))



class Enemy:
    def __init__(self, pos):
        self.pos = pos
        self.hitpoints = 1
        self.image = pygame.image.load("enemy_sprite.png").convert_alpha()
        self.rect = self.image.get_rect()
        self.rect.center = (pos.x + 20, pos.y + 20)
        self.rect.size = (45, 45)

    def update(self, screen, target, dt):
        direction = (target - self.pos).normalize()
        self.pos += direction * enemy_speed * dt
        self.rect.center = (self.pos.x + 50, self.pos.y + 50)
        screen.blit(self.image, self.pos)


class Bullet:
    def __init__(self, pos, direction):
        self.pos = pos
        self.direction = direction
        self.image = pygame.image.load("bullet_sprite.png").convert_alpha()
        self.rect = self.image.get_rect()
        self.rect.size = (10, 10)
        self.rect.center = (pos.x, pos.y)


    def update(self, screen, dt):
        self.pos += self.direction * 400 * dt
        self.rect.center = (self.pos.x, self.pos.y)
        angle = self.direction.angle_to((1, 0))
        bullet_rotated = pygame.transform.rotate(self.image, angle - 90)
        bullet_rotated_rect = bullet_rotated.get_rect(center=self.pos)
        screen.blit(bullet_rotated, bullet_rotated_rect)
        if not (0 <= bullet.pos.x <= screen.get_width() and 0 <= bullet.pos.y <= screen.get_height()):
            self.destroy()

    def is_colliding(self, other):
        return self.rect.colliderect(other.rect)

    def destroy(self):
        bullets.remove(self)


# pygame setup
pygame.init()
screen_size = (1280, 720)
screen = pygame.display.set_mode(screen_size)

clock = pygame.time.Clock()
running = True
dt = 0

player = Player(pygame.Vector2(screen.get_width() / 2, screen.get_height() / 2))

player_pos = pygame.Vector2(screen.get_width() / 2, screen.get_height() / 2)
cooldown_tracker = 0
cooldown = 300
last = pygame.time.get_ticks()

enemy_speed = 200

enemies = []
bullets = []

score = 0

while running:
    # poll for events
    # pygame.QUIT event means the user clicked X to close your window
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    # fill the screen with a color to wipe away anything from last frame
    screen.fill("black")

    # rotate the player rectangle to face the mouse

    mouse_pos = pygame.Vector2(pygame.mouse.get_pos())
    player.update(mouse_pos)

    # get the keys that are currently being pressed


    # player shooting with cooldown
    player.shoot(mouse_pos)

    # move and draw bullets
    for bullet in bullets:
        bullet.update(screen, dt)

    # remove bullets that are off-screen
    # bullets = [bullet for bullet in bullets if 0 <= bullet.pos.x <= screen.get_width()
    #            and 0 <= bullet.pos.y <= screen.get_height()]

    # spawn enemies
    if len(enemies) < 5:
        x_sides = [0, screen.get_width()]
        y_sides = [0, screen.get_height()]
        enemies.append(Enemy(pygame.Vector2(random.choice(x_sides), random.randint(0, screen.get_height()))))

    # move and draw enemies
    for enemy in enemies:
        enemy.update(screen, player.pos, dt)

    # check for bullet-enemy collisions
    for bullet in bullets:
        for enemy in enemies:
            if bullet.is_colliding(enemy):

                enemies.remove(enemy)
                bullets.remove(bullet)
                score += 1

    # check for player-enemy collisions
    for enemy in enemies:
        if player.rect.colliderect(enemy.rect):
            enemies.remove(enemy)
            score -= 1

    # write the score on the screen
    font = pygame.font.Font(None, 36)
    score_text = font.render(f"Score: {score}", True, "white")
    screen.blit(score_text, (10, 10))


    # flip() the display to put your work on screen
    pygame.display.flip()

    # limits FPS to 60
    # dt is delta time in seconds since last frame, used for framerate-
    # independent physics.
    dt = clock.tick(60) / 1000

pygame.quit()