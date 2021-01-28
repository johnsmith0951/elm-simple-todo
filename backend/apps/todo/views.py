from rest_framework import viewsets

from todo.models import TTodoTask
from todo.serializers import TodoTaskSerializer


class TodoViewSet(viewsets.ModelViewSet):
    queryset = TTodoTask.objects.all()
    serializer_class = TodoTaskSerializer
