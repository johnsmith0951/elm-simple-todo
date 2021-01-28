from django.db import models


class TTodoTask(models.Model):
    """
    ToDoタスクモデル
    """

    name = models.CharField(null=False, blank=False, max_length=255, verbose_name="タスク名")
    is_completed = models.BooleanField(null=False, default=False, verbose_name="完了フラグ")

    class Meta:
        db_table = "t_todo_task"

    def __str__(self):
        return f'{self.name} | {self.is_completed}'
