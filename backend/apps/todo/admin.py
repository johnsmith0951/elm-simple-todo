from django.contrib import admin

from todo.models import TTodoTask


class TodoAdmin(admin.ModelAdmin):
    pass

admin.site.register(TTodoTask, TodoAdmin)
