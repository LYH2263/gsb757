<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 - 网上书店</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body class="bg-gradient-to-r from-blue-500 to-indigo-600 h-screen flex items-center justify-center">

    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-5 col-lg-4">
                <div class="bg-white p-8 rounded-2xl shadow-2xl transform transition-all hover:scale-105 duration-300">
                    <div class="text-center mb-4">
                        <h2 class="text-3xl font-extrabold text-gray-800">欢迎回来</h2>
                        <p class="text-gray-500 mt-2">请登录您的账户</p>
                    </div>

                    <form id="loginForm" class="space-y-4">
                        <div>
                            <label for="username" class="form-label text-sm font-medium text-gray-700">用户名</label>
                            <input type="text" class="form-control rounded-lg border-gray-300 focus:ring-indigo-500 focus:border-indigo-500 transition-colors" id="username" name="username" value="admin" required>
                        </div>
                        <div>
                            <label for="password" class="form-label text-sm font-medium text-gray-700">密码</label>
                            <input type="password" class="form-control rounded-lg border-gray-300 focus:ring-indigo-500 focus:border-indigo-500 transition-colors" id="password" name="password" value="123456" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100 py-2.5 font-bold rounded-lg shadow-md hover:shadow-lg bg-indigo-600 hover:bg-indigo-700 border-none transition-all duration-300">
                            登 录
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;

            try {
                const res = await fetch('/api/login', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({username, password})
                });
                if (res.ok) {
                    Swal.fire({
                        icon: 'success',
                        title: '登录成功',
                        text: '正在跳转首页...',
                        timer: 1500,
                        showConfirmButton: false
                    }).then(() => {
                        window.location.href = 'index.jsp';
                    });
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: '登录失败',
                        text: '用户名或密码错误',
                        confirmButtonColor: '#4f46e5'
                    });
                }
            } catch (err) {
                console.error(err);
                Swal.fire({
                    icon: 'error',
                    title: '错误',
                    text: '发生未知错误',
                    confirmButtonColor: '#ef4444'
                });
            }
        });
    </script>
</body>
</html>
