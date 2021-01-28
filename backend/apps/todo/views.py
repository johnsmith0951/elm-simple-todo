from rest_framework import generics

from todo.models import TTodoTask
from todo.serializers import TodoTaskSerializer


class TodoList(generics.ListCreateAPIView):
    queryset = TTodoTask.objects.all()
    serializer_class = TodoTaskSerializer


