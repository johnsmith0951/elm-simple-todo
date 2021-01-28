from rest_framework import serializers

from todo.models import TTodoTask


class TodoTaskSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = TTodoTask
        fields = ['id', 'name', 'is_completed']