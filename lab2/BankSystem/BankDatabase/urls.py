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

    path("create_credit", views.create_credit, name="create_credit"),
    path("create_saving", views.create_saving, name="create_saving"),

    path("add_bank", views.add_bank, name="add_bank"),
    path("update_bank/<str:bank_name>/", views.update_bank, name="update_bank"),
    path('delete/<str:bank_name>/', views.delete_bank, name='delete_bank'),
    path("search_bank", views.search_bank, name="search_bank"),
    path("bank_info/<str:bank_name>/", views.get_bank_info, name="bank_info"),
]