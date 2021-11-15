from random import randrange as rnd, choice
import tkinter as tk
import math
import time

# print (dir(math))

root = tk.Tk()
fr = tk.Frame(root)
root.geometry('800x600')
canv = tk.Canvas(root, bg='white')
canv.pack(fill=tk.BOTH, expand=1)
LENGTH = 800
HEIGHT = 600

class ball():
    def __init__(self, x=40, y=450):
        """ Конструктор класса ball

        Args:
        x - начальное положение мяча по горизонтали
        y - начальное положение мяча по вертикали
        """
        self.x = x
        self.y = y
        self.r = 10
        self.vx = 0
        self.vy = 0
        self.color = choice(['blue', 'green', 'red', 'brown'])
        self.id = canv.create_oval(
                self.x - self.r,
                self.y - self.r,
                self.x + self.r,
                self.y + self.r,
                fill=self.color
        )
        self.live = 30

    def set_coords(self):
        canv.coords(
                self.id,
                self.x - self.r,
                self.y - self.r,
                self.x + self.r,
                self.y + self.r
        )

    def move(self):
        """Переместить мяч по прошествии единицы времени.

        Метод описывает перемещение мяча за один кадр перерисовки. То есть, обновляет значения
        self.x и self.y с учетом скоростей self.vx и self.vy, силы гравитации, действующей на мяч,
        и стен по краям окна (размер окна 800х600).
        """
        self.vy += 1
        if self.y > HEIGHT:
            self.vy = -abs(self.vy)
            self.vy *= 0.8
        if self.x > LENGTH:
            self.vx = -abs(self.vx)
        self.x += self.vx
        self.y += self.vy
        self.set_coords()


    def hittest(self, obj):
        """Функция проверяет сталкивалкивается ли данный обьект с целью, описываемой в обьекте obj.

        Args:
            obj: Обьект, с которым проверяется столкновение.
        Returns:
            Возвращает True в случае столкновения мяча и цели. В противном случае возвращает False.
        """
        if (self.x - obj.x) ** 2 + (self.y - obj.y) ** 2 <= (self.r + obj.r) ** 2:
            return True
        else:
            return False


class gun():
    def __init__(self):
        self.f2_power = 10
        self.f2_on = 0
        self.an = 1
        self.id = canv.create_line(20,450,50,420,width=7)

    def fire2_start(self, event):
        self.f2_on = 1

    def fire2_end(self, event):
        """Выстрел мячом.

        Происходит при отпускании кнопки мыши.
        Начальные значения компонент скорости мяча vx и vy зависят от положения мыши.
        """
        global balls, bullet
        bullet += 1
        new_ball = ball()
        new_ball.r += 5
        del_y = event.y - new_ball.y
        del_x = event.x - new_ball.x
        self.an = math.asin(del_y / (del_x ** 2 + del_y ** 2) ** 0.5)
        new_ball.vx = self.f2_power * math.cos(self.an)
        new_ball.vy = self.f2_power * math.sin(self.an)
        balls += [new_ball]
        self.f2_on = 0
        self.f2_power = 10


    def targetting(self, event=0):
        """Прицеливание. Зависит от положения мыши."""
        if event:
            self.an = math.asin((event.y - 450) / ((event.x - 20) ** 2 + (event.y - 450) ** 2) ** 0.5)
        if self.f2_on:
            canv.itemconfig(self.id, fill='orange')
        else:
            canv.itemconfig(self.id, fill='black')
        canv.coords(self.id, 20, 450,
                    20 + max(self.f2_power, 20) * math.cos(self.an),
                    450 + max(self.f2_power, 20) * math.sin(self.an)
                    )

    def power_up(self):
        if self.f2_on:
            if self.f2_power < 100:
                self.f2_power += 1
            canv.itemconfig(self.id, fill='orange')
        else:
            canv.itemconfig(self.id, fill='black')


class target():
    points = 0
    id_points = canv.create_text(30, 30, text=points, font='28')

    def __init__(self):
        self.live = 1
        self.id = canv.create_oval(0,0,0,0)
        self.new_target()
        self.move()


    def new_target(self):
        """ Инициализация новой цели. """
        x = self.x = rnd(600, 780)
        y = self.y = rnd(300, 550)
        r = self.r = rnd(15, 50)
        self.vx = rnd(1, 5)
        self.vy = rnd(1, 5)
        color = self.color = 'red'
        canv.coords(self.id, x-r, y-r, x+r, y+r)
        canv.itemconfig(self.id, fill=color)

    def hit(self, points=1):
        """Попадание шарика в цель."""
        canv.coords(self.id, -10, -10, -10, -10)
        target.points += points
        canv.itemconfig(target.id_points, text=target.points)

    def set_coords(self):
        canv.coords(
            self.id,
            self.x - self.r,
            self.y - self.r,
            self.x + self.r,
            self.y + self.r
        )

    def move(self):
        if self.live:
            self.y += self.vy
            self.x += self.vx
            if self.y + self.r > HEIGHT:
                self.vy = -abs(self.vy)
            if self.y - self.r < 0:
                self.vy = abs(self.vy)
            if self.x + self.r > LENGTH:
                self.vx = -abs(self.vx)
            if self.x - self.r < 0:
                self.vx = abs(self.vx)
            self.set_coords()
            root.after(50, self.move)



def new_game():
    global gun, t1, t2, screen1, balls, bullet
    canv.itemconfig(screen1, text='')
    t1.new_target()
    t2.new_target()
    bullet = 0
    balls = []
    canv.bind('<Button-1>', g1.fire2_start)
    canv.bind('<ButtonRelease-1>', g1.fire2_end)
    canv.bind('<Motion>', g1.targetting)

    z = 0.03
    t1.live = 1
    t2.live = 1
    t1.move()
    t2.move()
    while t1.live or balls:
        for b in balls:
            b.move()
            if b.hittest(t1) and t1.live:
                t1.live = 0
                t1.hit()
            if b.hittest(t2) and t2.live:
                t2.live = 0
                t2.hit()
            if t2.live == 0 and t1.live == 0:
                canv.bind('<Button-1>', '')
                canv.bind('<ButtonRelease-1>', '')
                canv.itemconfig(screen1, text='УБИЛ за ' + str(bullet) + ' МЯЧЕЙ!!!')
                for b in balls:
                    canv.delete(b.id)
                while balls:
                    balls.pop()
                break
        canv.update()
        time.sleep(z)
        g1.targetting()
        g1.power_up()
    canv.delete(gun)
    root.after(1000, new_game)

t1 = target()
t2 = target()
g1 = gun()
screen1 = canv.create_text(LENGTH / 2, HEIGHT / 2, text='', font='40')
bullet = 0
balls = []
new_game()
root.mainloop()
