from django.urls import path, re_path, include
from BankDatabase import views

app_name = 'banksystem'

urlpatterns = [
    path("client/", views.client_management, name="client"),
    path("account/", views.account_management, name="account"),
    path("bankinfo/", views.bankinfo_management, name="bankinfo"),
    path("loan/", views.loan_management, name="loan"),
    path("add_client/", views.client_add, name="add_client"),
    path("delete_client", views.delete_client, name="delete_client"),
    path("modify_client", views.modify_client, name="modify_client"),
    path("search_client", views.search_client, name="search_client"),
    path("detail_client", views.client_detail, name="detail_client"),
    path('detail_client/<str:client_id>/', views.client_detail, name='detail_client'),
    path('delete_client/<str:client_id>/', views.delete_client_detail, name='delete_client'),
    path('modify_client/<str:client_id>/', views.modify_client_detail, name='modify_client'),
]