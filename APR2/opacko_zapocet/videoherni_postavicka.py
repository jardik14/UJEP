class Hero:

    total_hero_kill_count = 0

    def __init__(self, name:str, hero_class:str, max_health:int, damage=int):
        self.name = name
        self.hero_class = hero_class
        self.max_health = max_health
        self.health = max_health
        self.kill_count = 0
        self.damage = damage

    @property
    def health(self):
        return self.health

    @health.setter
    def health(self, value):
        self.health = value


    def take_damage(self, value):
        self.health -= value

    def attack(self, other:'Hero'):
        other.take_damage(self.damage)
        if other.health <= 0:
            self.kill_count += 1
            Hero.total_hero_kill_count += 1

    def get_total_kill_count(cls):
        return cls.total_hero_kill_count

    def __str__(self):
        return f"Name: {self.name}, Class: {self.hero_class}, Kills: {self.kill_count}"

    def __bool__(self):
        return self.health > 0


