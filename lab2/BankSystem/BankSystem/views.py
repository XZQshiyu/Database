from django.http import HttpResponse
from django.shortcuts import render
from django.contrib import messages

def signin(request):
    if request.method == 'POST':
        data = request.POST.dict()

        # 验证表单数据的有效性
        username = data.get("user")
        password = data.get("password")

        if username and password:
            if username == "lyz" and password == "Lyz791387210":
                return render(request, "index.html")
            else:
                messages.error(request, "Invalid username or passowrd")
        else:
            messages.error(request, "Both username and password are required to log in")
    return render(request, "signin.html")
        
def index(request):
    return render(request, "index.html")


