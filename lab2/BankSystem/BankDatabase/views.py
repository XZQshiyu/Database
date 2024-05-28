from django.shortcuts import render

# Create your views here.

def client_management(request):
    return render(request, "client/client_management.html")

def loan_management(request):
    return render(request, "loan/loan_management.html")

def account_management(request):
    return render(request, "account/account_management.html")

def bankinfo_management(request):
    return render(request, "bankinfo/bankinfo_management.html")

