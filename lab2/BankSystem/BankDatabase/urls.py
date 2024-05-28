from django.urls import path, re_path, include
from BankDatabase import views

urlpatterns = [
    path("client/", views.client_management),
    path("account/", views.account_management),
    path("bankinfo/", views.bankinfo_management),
    path("loan/", views.loan_management),
]