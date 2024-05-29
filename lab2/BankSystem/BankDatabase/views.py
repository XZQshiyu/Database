from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.db import connection
from django.urls import reverse
from django.views.decorators.csrf import csrf_protect
from django.http import HttpResponseNotFound
# Create your views here.

def client_management(request):
    with connection.cursor() as cursor:
        cursor.callproc('get_all_clients')
        results = cursor.fetchall()
    return render(request, "client/client_management.html", {"clients": results})

def loan_management(request):
    return render(request, "loan/loan_management.html")

def account_management(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM credit_account")
        credit_accounts = cursor.fetchall()
        cursor.execute("SELECT * FROM saving_account")
        saving_accounts = cursor.fetchall()
    accounts = credit_accounts + saving_accounts
    return render(request, "account/account_management.html", {"accounts": accounts})

def bankinfo_management(request):
    return render(request, "bankinfo/bankinfo_management.html")

# 客户管理

# 客户添加
def client_add(request):
    if request.method == 'POST':
        # 获取表单数据
        client_id = request.POST.get('client_id')
        id_number = request.POST.get('id')
        name = request.POST.get('name')
        sex = request.POST.get('sex')
        address = request.POST.get('address')
        phone = request.POST.get('phone')
        email = request.POST.get('email')
        contact_name = request.POST.get('contact_name')
        contact_phone = request.POST.get('contact_phone')
        contact_email = request.POST.get('contact_email')
        contact_relation = request.POST.get('contact_relation')

        #初始化错误信息
        errors = {}

        # 检查id，要求为正整数
        if not client_id:
            errors['client_id'] = 'id 不能为空'
        else:
            try:
                client_id = int(client_id)
                if client_id <= 0:
                    errors['client_id'] = 'id必须是正整数'
            except ValueError:
                errors['client_id'] = 'id 必须是正整数'
        
        # 检查身份证
        if not id_number:
            errors['id_number'] = '身份证不能为空'
        
        # 检查姓名
        if not name:
            errors['name'] = '姓名不能为空'
        # 检查性别
        if sex not in ['男', '女']:
            errors['sex'] = "请认真填写性别"
        # 检查地址
        if not address:
            errors['address'] = '地址不能为空' 
        if not phone:
            errors['phone'] = '联系方式不能为空'
        if not email:
            errors['email'] = '邮箱不能为空'
        if not contact_name:
            errors['contact_name'] = '联系人名字不能为空'
        if not contact_phone:
            errors['contact_phone'] = '联系人电话不能为空'
        if not contact_relation:
            errors['contact_relation'] = '联系人关系不能为空'
        if not contact_email:
            errors['contact_email'] = '联系人邮箱不能为空'
        
        # 调用存储过程
        with connection.cursor() as cursor:
            err = ''
            cursor.callproc('add_client', [client_id, id_number, name, sex, address, phone, email, 
                contact_name, contact_phone, contact_email, contact_relation, err
            ])
            cursor.execute('SELECT @_add_client_11')
            err = cursor.fetchone()[0]
            print(err)
            if err:
                errors['database'] = 'err'
                return render(request, "client/add_client.html", {"errors": errors})
            else:
                return redirect(reverse("banksystem:client"))
    return render(request, "client/add_client.html")

def delete_client(request):
    if request.method == 'POST':
        client_id = request.POST.get('client_id')
        errors = {}

        if not client_id:
            errors['client_id'] = 'Client ID cannot be empty'
        else:
            with connection.cursor() as cursor:
                err = ''
                cursor.callproc("delete_client", [client_id, err])
                cursor.execute("SELECT @_delete_client_1")
                err = cursor.fetchone()[0]
                if err:
                    errors['database'] = err
        if errors:
            return render(request, "client/delete_client.html", {"errors": errors})
        else:
            return redirect(reverse("banksystem:client"))

    return render(request, "client/delete_client.html")           

def modify_client(request):
    if request.method == 'POST':
        client_id = request.POST.get('client_id')
        id_number = request.POST.get('id')
        name = request.POST.get('name')
        sex = request.POST.get('sex')
        address = request.POST.get('address')
        phone = request.POST.get('phone')
        email = request.POST.get('email')
        contact_name = request.POST.get('contact_name')
        contact_phone = request.POST.get('contact_phone')
        contact_email = request.POST.get('contact_email')
        contact_relation = request.POST.get('contact_relation')

        errors = {}

        if not client_id:
            errors['client_id'] = 'Client ID cannot be empty.'
        
        if not errors:
            with connection.cursor() as cursor:
                err = ''
                cursor.callproc('modify_client', [
                    client_id, id_number or None, name or None, sex or None,
                    address or None, phone or None, email or None, 
                    contact_name or None, contact_phone or None, 
                    contact_email or None, contact_relation or None, err
                ])
                cursor.execute('SELECT @_modify_client_11')
                err = cursor.fetchone()[0]
                if err:
                    errors['database'] = err

        if errors:
            return render(request, "client/modify_client.html", {"errors": errors})
        else:
            return redirect(reverse("banksystem:client"))

    return render(request, "client/modify_client.html")

def search_client(request):
    results = []
    if request.method == 'POST':
        client_id = request.POST.get('client_id', None)
        name = request.POST.get('name', None)

        with connection.cursor() as cursor:
            cursor.callproc('search_client', [client_id, name])
            results = cursor.fetchall()
    return render(request, "client/search_client.html", {"results": results})

def client_detail(request, client_id):
    with connection.cursor() as cursor:
        cursor.callproc('get_client_detail', [client_id])
        result = cursor.fetchall()
    
    if result:
        client = result[0]
    else:
        client = None

    return render(request, "client/client_detail.html", {"client": client})

def delete_client_detail(request, client_id):
    errors = {}
    with connection.cursor() as cursor:
        err = ''
        cursor.callproc('delete_client', [client_id, err])
        cursor.execute('SELECT @_delete_client_1')
        error = cursor.fetchone()[0]
        if error:
            errors['database'] = error
            return render(request, "client/client_management.html", {"errors": errors})
        else:
            return redirect(reverse('banksystem:client'))

def modify_client_detail(request, client_id):
    # 查询客户信息
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM client WHERE client_id = %s", [client_id])
        client = cursor.fetchone()
    
    if not client:
        return HttpResponseNotFound("Client not found")

    if request.method == 'POST':
        # 获取表单数据
        name = request.POST.get('name')
        sex = request.POST.get('sex')
        address = request.POST.get('address')
        phone = request.POST.get('phone')
        email = request.POST.get('email')
        contact_name = request.POST.get('contact_name')
        contact_phone = request.POST.get('contact_phone')
        contact_email = request.POST.get('contact_email')
        contact_relation = request.POST.get('contact_relation')

        # 更新客户信息
        with connection.cursor() as cursor:
            cursor.execute(
                "UPDATE client SET name=%s, sex=%s, address=%s, phone=%s, email=%s, "
                "contact_name=%s, contact_phone=%s, contact_email=%s, contact_relation=%s "
                "WHERE client_id=%s",
                [name, sex, address, phone, email, contact_name, contact_phone, contact_email, contact_relation, client_id]
            )
        
        # 重定向到客户详情页面
        return redirect(reverse('banksystem:detail_client', kwargs={'client_id': client_id}))

    return render(request, 'client/modify_client_detail.html', {'client': client})