<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的订单 - 网上书店</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .order-card { transition: all 0.3s ease; }
        .order-card:hover { box-shadow: 0 10px 30px rgba(0,0,0,0.08); }
        .order-detail { max-height: 0; overflow: hidden; transition: max-height 0.4s ease, padding 0.3s ease; }
        .order-detail.expanded { max-height: 1000px; }
        .toggle-icon { transition: transform 0.3s ease; }
        .toggle-icon.rotated { transform: rotate(180deg); }
        .status-badge { font-size: 0.75rem; letter-spacing: 0.05em; }
    </style>
</head>
<body class="bg-gray-50 min-h-screen flex flex-col">

    <nav class="navbar navbar-expand-lg bg-white shadow-sm py-3 sticky-top">
        <div class="container">
            <a class="navbar-brand font-bold text-2xl text-indigo-600 flex items-center gap-2" href="index.jsp">
                <i class="fas fa-book-open"></i> 网上书店
            </a>
            <div class="d-flex gap-3">
                <a href="index.jsp" class="btn btn-outline-secondary rounded-full px-4 font-medium transition-all">
                    <i class="fas fa-arrow-left me-2"></i> 继续购物
                </a>
                <a href="cart.jsp" class="btn btn-outline-primary rounded-full px-4 border-2 hover:bg-indigo-50 hover:border-indigo-600 hover:text-indigo-600 font-medium transition-all">
                    <i class="fas fa-shopping-cart me-2"></i> 购物车
                </a>
                <button onclick="logout()" class="btn btn-danger rounded-full px-4 font-medium transition-all hover:shadow-md">
                    <i class="fas fa-sign-out-alt me-2"></i> 退出
                </button>
            </div>
        </div>
    </nav>

    <div class="container my-5 flex-grow-1">
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden p-6">
            <h2 class="text-3xl font-bold mb-6 text-gray-800 border-b pb-4">
                <i class="fas fa-receipt text-indigo-600 me-2"></i>我的订单
            </h2>

            <div id="orderList">
                <div class="text-center py-10">
                    <div class="spinner-border text-indigo-600" role="status">
                        <span class="visually-hidden">加载中...</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="bg-white py-6 mt-auto border-t">
        <div class="container text-center text-gray-500 text-sm">
            &copy; 2024 Bookstore Inc. 版权所有.
        </div>
    </footer>

    <script>
        function formatPrice(amount) {
            return '¥' + Number(amount).toFixed(2);
        }

        function formatDate(timestamp) {
            const date = new Date(timestamp);
            const y = date.getFullYear();
            const m = String(date.getMonth() + 1).padStart(2, '0');
            const d = String(date.getDate()).padStart(2, '0');
            const h = String(date.getHours()).padStart(2, '0');
            const min = String(date.getMinutes()).padStart(2, '0');
            const s = String(date.getSeconds()).padStart(2, '0');
            return y + '-' + m + '-' + d + ' ' + h + ':' + min + ':' + s;
        }

        function getStatusLabel(status) {
            const map = {
                'COMPLETED': { label: '已完成', bg: 'bg-green-100', text: 'text-green-700' },
                'PENDING': { label: '待处理', bg: 'bg-yellow-100', text: 'text-yellow-700' },
                'CANCELLED': { label: '已取消', bg: 'bg-red-100', text: 'text-red-700' }
            };
            const info = map[status] || { label: status, bg: 'bg-gray-100', text: 'text-gray-700' };
            return '<span class="status-badge px-3 py-1 rounded-full font-bold ' + info.bg + ' ' + info.text + '">' + info.label + '</span>';
        }

        function toggleDetail(orderId) {
            const detail = document.getElementById('detail-' + orderId);
            const icon = document.getElementById('icon-' + orderId);
            detail.classList.toggle('expanded');
            icon.classList.toggle('rotated');
        }

        function renderOrders(orders) {
            const container = document.getElementById('orderList');

            if (!orders || orders.length === 0) {
                container.innerHTML = `
                    <div class="text-center py-16">
                        <i class="fas fa-box-open text-6xl text-gray-300 mb-4"></i>
                        <p class="text-xl text-gray-500 mb-2">暂无订单记录</p>
                        <p class="text-gray-400 mb-6">快去挑选心仪的图书吧！</p>
                        <a href="index.jsp" class="inline-block bg-indigo-600 text-white px-6 py-3 rounded-xl font-bold hover:bg-indigo-700 hover:shadow-lg transition-all">
                            <i class="fas fa-shopping-bag me-2"></i>去购物
                        </a>
                    </div>`;
                return;
            }

            container.innerHTML = orders.map(function(order) {
                const itemsHtml = (order.items || []).map(function(item) {
                    const subtotal = (Number(item.price) * item.quantity).toFixed(2);
                    return `
                        <tr class="hover:bg-gray-50 transition-colors">
                            <td class="py-3 px-4">
                                <span class="font-bold text-gray-800">${item.book.title}</span>
                                <br><span class="text-xs text-gray-400">${item.book.author}</span>
                            </td>
                            <td class="py-3 px-4 text-indigo-600 font-semibold">${formatPrice(item.price)}</td>
                            <td class="py-3 px-4">
                                <span class="bg-gray-100 px-3 py-1 rounded-full text-xs font-bold">${item.quantity}</span>
                            </td>
                            <td class="py-3 px-4 font-bold">${formatPrice(subtotal)}</td>
                        </tr>`;
                }).join('');

                return `
                    <div class="order-card bg-white border border-gray-200 rounded-xl mb-4 overflow-hidden">
                        <div class="flex flex-col md:flex-row md:items-center justify-between p-5 cursor-pointer hover:bg-gray-50 transition-colors" onclick="toggleDetail(${order.id})">
                            <div class="flex flex-wrap items-center gap-4 mb-2 md:mb-0">
                                <span class="text-sm text-gray-500 font-mono">订单号: <span class="text-gray-800 font-bold">#${String(order.id).padStart(6, '0')}</span></span>
                                <span class="text-sm text-gray-500"><i class="far fa-clock me-1"></i>${formatDate(order.createdAt)}</span>
                                ${getStatusLabel(order.status)}
                            </div>
                            <div class="flex items-center gap-4">
                                <span class="text-lg font-bold text-indigo-600">${formatPrice(order.totalAmount)}</span>
                                <i id="icon-${order.id}" class="fas fa-chevron-down toggle-icon text-gray-400"></i>
                            </div>
                        </div>
                        <div id="detail-${order.id}" class="order-detail">
                            <div class="px-5 pb-5">
                                <div class="border-t pt-4">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="bg-gray-100 text-gray-600 uppercase text-xs tracking-wider">
                                            <tr>
                                                <th class="py-3 px-4">书名</th>
                                                <th class="py-3 px-4">单价</th>
                                                <th class="py-3 px-4">数量</th>
                                                <th class="py-3 px-4">小计</th>
                                            </tr>
                                        </thead>
                                        <tbody class="text-sm font-medium text-gray-700 divide-y divide-gray-200">
                                            ${itemsHtml}
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>`;
            }).join('');
        }

        async function loadOrders() {
            try {
                const res = await fetch('/order/list');
                if (res.status === 401) {
                    window.location.href = 'login.jsp';
                    return;
                }
                if (!res.ok) {
                    throw new Error('Server error');
                }
                const orders = await res.json();
                renderOrders(orders);
            } catch (err) {
                console.error(err);
                document.getElementById('orderList').innerHTML = `
                    <div class="text-center py-10 text-red-500">
                        <i class="fas fa-exclamation-triangle text-4xl mb-3"></i>
                        <p>加载订单失败，请稍后重试</p>
                    </div>`;
            }
        }

        async function logout() {
            try {
                await fetch('/api/logout', { method: 'POST' });
                window.location.href = 'login.jsp';
            } catch(e) {
                console.error(e);
            }
        }

        loadOrders();
    </script>
</body>
</html>
