from django import template

register = template.Library()

@register.filter(name='equals')
def equals(value, arg):
    return value == arg 