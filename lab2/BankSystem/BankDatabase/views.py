from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.db import connection
from django.urls import reverse
from django.views.decorators.csrf import csrf_protect
from django.http import HttpResponseNotFound
from django.contrib import messages
# Create your views here.

def client_management(request):
    with connection.cursor() as cursor:
        cursor.callproc('get_all_clients')
        results = cursor.fetchall()
    return render(request, "client/client_management.html", {"clients": results})

def loan_management(request):
    with connection.cursor() as cursor:
        cursor.callproc('get_all_loans')
        results = cursor.fetchall()

    return render(request, "loan/loan_management.html", {"loans": results})

def account_management(request):
    with connection.cursor() as cursor:
        # 获取储蓄账户信息，包括利率和所有者
        cursor.callproc('get_saving_account_by_all')
        saving_accounts = cursor.fetchall()
        
        # 获取信用账户信息，包括透支额度和所有者
        cursor.callproc('get_credit_account_by_all')
        credit_accounts = cursor.fetchall()
    
    # 合并账户信息
    accounts = saving_accounts + credit_accounts
    
    return render(request, 'account/account_management.html', {'accounts': accounts})

def bankinfo_management(request):
    with connection.cursor() as cursor:
        cursor.execute("CALL GetAllBanks()")
        banks = cursor.fetchall()

    return render(request, "bankinfo/bankinfo_management.html", {"banks": banks})

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


# 账户管理
def create_credit(request):
    if request.method == 'POST':
        account_id = request.POST['account_id']
        bank_name = request.POST['bank_name']
        balance = float(request.POST['balance'])
        open_date = request.POST['open_date']
        overdraft = float(request.POST['overdraft'])
        client_id = request.POST['client_id']

        with connection.cursor() as cursor:
            cursor.callproc('create_credit_account',[account_id, bank_name, balance, open_date, overdraft, client_id])
        
        return redirect(reverse('banksystem:account'))
    else:
        return render(request, 'account/create_credit.html')

def create_saving(request):
    if request.method == 'POST':
        account_id = request.POST['account_id']
        bank_name = request.POST['bank_name']
        balance = float(request.POST['balance'])
        open_date = request.POST['open_date']
        rate = float(request.POST['rate'])
        client_id = request.POST['client_id']
        
        with connection.cursor() as cursor:
            cursor.callproc('create_saving_account', [account_id, bank_name, balance, open_date, rate, client_id])
        return redirect(reverse('banksystem:account'))
    else:
        return render(request, 'account/create_saving.html')

# 查看账户信息
def view_account(request, account_id):
    with connection.cursor() as cursor:
        cursor.callproc('get_saving_account_by_id', [account_id])
        account = cursor.fetchone()
        if not account:
            cursor.callproc('get_credit_account_by_id', [account_id])
            account = cursor.fetchone()
    return render(request, 'account/view_account.html', {'account': account})


def update_account(request, account_id, account_type):
    with connection.cursor() as cursor:
        if(account_type == 'saving'):
            cursor.execute("SELECT * FROM saving_account WHERE account_id = %s", [account_id])
            account = cursor.fetchone()
        else:
            cursor.execute("SELECT * FROM credit_account WHERE account_id = %s", [account_id])
            account = cursor.fetchone()
    if not account:
        return HttpResponseNotFound("Account not found")
    
    if request.method == 'POST':
        bank_name = request.POST.get('bank_name')
        balance = request.POST.get('balance')
        if(account_type == 'saving'):
            rate = request.POST.get('rate')
            with connection.cursor() as cursor:
                cursor.callproc('update_saving_account_by_account_id', [account_id, bank_name, balance, rate])
        else:
            overdraft = request.POST.get('overdraft')
            with connection.cursor() as cursor:
                cursor.callproc('update_credit_account_by_account_id', [account_id, bank_name, balance, overdraft])
        
        return redirect(reverse('banksystem:view_account', kwargs={'account_id': account_id}))
    return render(request, 'account/update_account.html', {'account_id': account_id, 'account_type': account_type, 'account': account})

def delete_account(request, account_id, account_type):
    try:
        with connection.cursor() as cursor:
            if account_type == 'saving':
                cursor.callproc('delete_saving_account_by_account_id', [account_id])
            else:
                cursor.callproc('delete_credit_account_by_account_id', [account_id])
        messages.success(request, 'Account deleted successfully')
        print('Account deleted successfully')
    except Exception as e:
        messages.error(request, 'Error deleting account: ' + str(e))
        print('Error deleting account: ' + str(e))
    return redirect(reverse('banksystem:account'))

def search_account(request):
    results = []
    if request.method == 'POST':
        account_id = request.POST.get('account_id', None)
        bank_name = request.POST.get('bank_name', None)
        name = request.POST.get('name', None)
        client_id = request.POST.get('client_id', None)
        print(account_id, bank_name, name, client_id)
        with connection.cursor() as cursor:
            cursor.callproc('search_saving_account', [client_id, account_id, bank_name, name])
            saving_accounts = cursor.fetchall()
        with connection.cursor() as cursor:
            cursor.callproc('search_credit_account', [client_id, account_id, bank_name, name])
            credit_accounts = cursor.fetchall()
        results = saving_accounts + credit_accounts
        print(results)
    return render(request, "account/search_account.html", {"results": results})

# 银行信息管理
def add_bank(request):
    if request.method == 'POST':
        bank_name = request.POST.get('bank_name')
        location = request.POST.get('location')
        asset = request.POST.get('asset')

        try:
            with connection.cursor() as cursor:
                cursor.execute("CALL AddBank(%s, %s, %s)", [bank_name, location, asset])
            messages.success(request, "Bank added successfully")
        except Exception as e:
            messages.error(request, "添加银行时出错: " + str(e))
        return redirect(reverse('banksystem:bankinfo'))
    
    return render(request, 'bankinfo/add_bank.html')

def update_bank(request, bank_name):
    if request.method == 'POST':
        location = request.POST['location']
        asset = request.POST['asset']
        
        try:
            with connection.cursor() as cursor:
                cursor.execute("CALL UpdateBank(%s, %s, %s)", [bank_name, location, asset])
            messages.success(request, '银行信息更新成功！')
        except Exception as e:
            messages.error(request, '更新银行信息时出错：' + str(e))
        
        return redirect('banksystem:bankinfo')
    
    with connection.cursor() as cursor:
        cursor.execute("CALL GetBankByName(%s)", [bank_name])
        bank = cursor.fetchone()
    
    return render(request, 'bankinfo/update_bank.html', {'bank': bank})

def delete_bank(request, bank_name):
    try:
        with connection.cursor() as cursor:
            cursor.execute("CALL DeleteBank(%s)", [bank_name])
        messages.success(request, '银行删除成功！')
    except Exception as e:
        messages.error(request, '删除银行时出错：' + str(e))
    
    return redirect('banksystem:bankinfo')

def search_bank(request):
    results = []
    if request.method == 'POST':
        bank_name = request.POST.get('bank_name', None)
        location = request.POST.get('location', None)

        with connection.cursor() as cursor:
            cursor.callproc('search_bank', [bank_name, location])
            results = cursor.fetchall()
    return render(request, "bankinfo/search_bank.html", {"results": results})

def get_bank_info(request, bank_name):
    with connection.cursor() as cursor:
        cursor.callproc('search_bank', [bank_name, None])
        results = cursor.fetchall()
    with connection.cursor() as cursor:
        cursor.callproc('get_departments_by_bank', [bank_name])
        departments = cursor.fetchall()
    print(departments)
    return render(request, 'bankinfo/bank_info.html', {'results':results, 'departments': departments})

def add_department(request, bank_name):
    if request.method == 'POST':
        department_id = request.POST.get('department_id')
        department_name = request.POST.get('department_name')
        department_type = request.POST.get('department_type')
        with connection.cursor() as cursor:
            cursor.callproc('add_department', [department_id, bank_name, department_name, department_type]) 
        return redirect(reverse('banksystem:bank_info', kwargs={'bank_name': bank_name}))
    return render(request, 'bankinfo/add_department.html')

def delete_department(request, bank_name, department_id):
    with connection.cursor() as cursor:
        cursor.callproc('delete_department', [department_id])
    return redirect(reverse('banksystem:bank_info', kwargs={'bank_name': bank_name}))

def update_department(request, bank_name, department_id):
    if request.method == 'POST':
        department_name = request.POST.get('department_name')
        department_type = request.POST.get('department_type')
        with connection.cursor() as cursor:
            cursor.callproc('update_department', [department_id, department_name, department_type]) 
        return redirect(reverse('banksystem:bank_info', kwargs={'bank_name': bank_name}))
    else:
        # 获取部门信息并显示在页面上
        with connection.cursor() as cursor:
            cursor.callproc('get_department_by_id', [department_id])
            department_info = cursor.fetchone()
        return render(request, 'bankinfo/update_department.html', {'department_id': department_info[0], 'department_name': department_info[2], 'department_type': department_info[3]})

def search_department(request, bank_name):
    results = []
    if request.method == 'POST':
        department_id = request.POST.get('department_id', None)
        department_name = request.POST.get('department_name', None)

        with connection.cursor() as cursor:
            print(department_id, department_name)
            cursor.callproc('search_department', [department_id, department_name, bank_name])
            results = cursor.fetchall()
            print(results)
    return render(request, "bankinfo/search_department.html", {"bank_name": bank_name, "departments": results})

# 员工信息管理

def get_employees_by_department(request, bank_name, department_id):
    employees = []
    if request.method == 'GET':
        with connection.cursor() as cursor:
            cursor.callproc('get_employee_by_department_id', [department_id])
            employees = cursor.fetchall()
    return render(request, 'bankinfo/employee_list.html', {'bank_name': bank_name, 'department_id':department_id, 'employees': employees})

def add_employee(request, bank_name, department_id):
    if request.method == 'POST':
        employee_id = request.POST.get('employee_id')
        id_number = request.POST.get('id')
        name = request.POST.get('name')
        sex = request.POST.get('sex')
        phone = request.POST.get('phone')
        address = request.POST.get('address')
        start_work_date = request.POST.get('start_work_date')
        with connection.cursor() as cursor:
            cursor.callproc('add_employee', [employee_id, department_id, id_number, name, sex, phone, address, start_work_date]) 
        return redirect(reverse('banksystem:employee_list', kwargs={'bank_name': bank_name, 'department_id': department_id}))
    return render(request, 'bankinfo/add_employee.html')

def delete_employee(request, bank_name, department_id, employee_id):
    with connection.cursor() as cursor:
        cursor.callproc('delete_employee', [employee_id])
    return redirect(reverse('banksystem:employee_list', kwargs={'bank_name': bank_name, 'department_id': department_id}))

def update_employee(request, bank_name, department_id, employee_id):
    if request.method == 'POST':
        id_number = request.POST.get('id')
        name = request.POST.get('name')
        sex = request.POST.get('sex')
        phone = request.POST.get('phone')
        address = request.POST.get('address')
        start_work_date = request.POST.get('start_work_date')
        with connection.cursor() as cursor:
            cursor.callproc('update_employee', [employee_id, department_id, id_number, name, sex, phone, address, start_work_date])
        return redirect(reverse('banksystem:employee_list', kwargs={'bank_name': bank_name, 'department_id': department_id}))
    else:
        with connection.cursor() as cursor:
            cursor.callproc('get_employee_by_id', [employee_id])
            employee_info = cursor.fetchone()
        return render(request, 'bankinfo/update_employee.html', {'employee_id': employee_info[0], 'id_number': employee_info[2], 'name': employee_info[3], 'sex': employee_info[4], 'phone': employee_info[5], 'address': employee_info[6], 'start_work_date': employee_info[7]})

def search_employee(request, bank_name, department_id):
    results = []
    if request.method == 'POST':
        employee_id = request.POST.get('employee_id', None)
        name = request.POST.get('name', None)

        with connection.cursor() as cursor:
            cursor.callproc('search_employee', [employee_id, name, department_id])
            results = cursor.fetchall()
    return render(request, "bankinfo/search_employee.html", {"bank_name": bank_name, "department_id": department_id, "employees": results})


# 贷款管理

# 查看贷款具体信息
def view_loan(request, loan_id):
    with connection.cursor() as cursor:
        cursor.callproc('get_loan_by_id', [loan_id])
        loan = cursor.fetchone()
    return render(request, 'loan/view_loan.html', {'loan': loan})

def add_loan(request):
    if request.method == 'POST':
        loan_id = request.POST.get('loan_id')
        client_id = request.POST.get('client_id')
        bank_name = request.POST.get('bank_name')
        loan_money = request.POST.get('loan_money')
        loan_rate = request.POST.get('loan_rate')
        loan_date = request.POST.get('loan_date')

        try:
            with connection.cursor() as cursor:
                cursor.callproc('add_loan', [loan_id, client_id, bank_name, loan_money, loan_rate, loan_date])
            messages.success(request, 'Loan added successfully')
        except Exception as e:
            messages.error(request, 'Error adding loan: ' + str(e))
        return redirect(reverse('banksystem:loan'))
    else:
        return render(request, 'loan/add_loan.html')

def update_loan(request, loan_id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM loan WHERE loan_id = %s", [loan_id])
        loan = cursor.fetchone()
    if not loan:
        return HttpResponseNotFound("Loan not found")

    if request.method == 'POST':
        client_id = request.POST.get('client_id')
        bank_name = request.POST.get('bank_name')
        loan_money = request.POST.get('loan_money')
        loan_rate = request.POST.get('loan_rate')
        with connection.cursor() as cursor:
            cursor.callproc('update_loan', [loan_id, client_id, bank_name ,loan_money, loan_rate])
        return redirect(reverse('banksystem:view_loan', kwargs={'loan_id': loan_id}))
    return render(request, 'loan/update_loan.html', {'loan_id': loan_id, 'loan': loan})

# 删除贷款
def delete_loan(request, loan_id):
    try:
        with connection.cursor() as cursor:
            cursor.callproc('delete_loan', [loan_id])
        messages.success(request, 'Loan deleted successfully')
    except Exception as e:
        messages.error(request, 'Error deleting loan: ' + str(e))
    return redirect(reverse('banksystem:loan'))

def search_loan(request):
    results = []
    if request.method == 'POST':
        loan_id = request.POST.get('loan_id', None)
        client_id = request.POST.get('client_id', None)
        bank_name = request.POST.get('bank_name', None)
        name = request.POST.get('name', None)

        with connection.cursor() as cursor:
            cursor.callproc('search_loan', [loan_id, client_id, bank_name, name])
            results = cursor.fetchall()
    return render(request, "loan/search_loan.html", {"results": results})

def loan_payment(request, loan_id):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM loan WHERE loan_id = %s", [loan_id])
        loan = cursor.fetchone()
    if not loan:
        return HttpResponseNotFound("Loan not found")

    with connection.cursor() as cursor:
        cursor.execute("SELECT pay_id FROM pay_loan WHERE loan_id = %s", [loan_id])
        pay_ids = cursor.fetchall()
    if request.method == 'POST':
        if pay_ids:
            pay_id = pay_ids[-1][0] + 1
        else:
            pay_id = 0
        pay_money = request.POST.get('pay_money')
        pay_date = request.POST.get('pay_date')
        with connection.cursor() as cursor:
            cursor.callproc('add_loan_payment', [pay_id, pay_money, pay_date, loan_id])
        return redirect(reverse('banksystem:loan'))
    return render(request, 'loan/loan_payment.html', {'loan_id': loan_id, 'loan': loan})

def loan_pay_info(request, loan_id):
    with connection.cursor() as cursor:
        cursor.callproc('get_loan_payment', [loan_id])
        loan_pay_info = cursor.fetchall()
    return render(request, 'loan/loan_pay_info.html', {'loan_pay_info': loan_pay_info})