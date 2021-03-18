import json

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response

from todo.models import TTodoTask
from todo.serializers import TodoTaskSerializer


class TodoListView(viewsets.ModelViewSet):
    queryset = TTodoTask.objects.all()
    serializer_class = TodoTaskSerializer

    @action(detail=False, methods=['DELETE'], name='Delete Records')
    def delete(self, request, pk=None):
        ids = json.loads(request.POST["ids"])
        TTodoTask.objects.filter(pk__in=ids).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

