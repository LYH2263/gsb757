<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的订单 - 网上书店</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-50 min-h-screen flex flex-col">

    <!-- Navbar -->
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
            </div>
        </div>
    </nav>

    <div class="container my-5 flex-grow-1">
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden p-6">
            <h2 class="text-3xl font-bold mb-6 text-gray-800 border-b pb-4">
                <i class="fas fa-receipt me-3 text-indigo-600"></i>我的订单
            </h2>

            <!-- Loading Spinner -->
            <div id="loading" class="text-center py-10">
                <div class="spinner-border text-indigo-600" role="status">
                    <span class="visually-hidden">加载中...</span>
                </div>
                <p class="mt-3 text-gray-500">正在加载订单数据...</p>
            </div>

            <!-- Orders List -->
            <div id="ordersList" class="space-y-4 hidden">
                <!-- Orders will be loaded here -->
            </div>

            <!-- Empty State -->
            <div id="emptyState" class="text-center py-16 hidden">
                <div class="flex flex-col items-center">
                    <i class="fas fa-box-open text-6xl mb-4 text-gray-300"></i>
                    <h3 class="text-xl font-semibold text-gray-600 mb-2">暂无订单</h3>
                    <p class="text-gray-400 mb-6">您还没有任何订单记录，快去挑选心仪的图书吧！</p>
                    <a href="index.jsp" class="btn bg-indigo-600 text-white rounded-lg px-6 py-2 hover:bg-indigo-700 hover:shadow-lg transition-all">
                        <i class="fas fa-shopping-bag me-2"></i>去购物
                    </a>
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
        function formatPrice(price) {
            return '¥' + Number(price).toFixed(2);
        }

        function formatDate(dateStr) {
            const date = new Date(dateStr);
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            const hours = String(date.getHours()).padStart(2, '0');
            const minutes = String(date.getMinutes()).padStart(2, '0');
            const seconds = String(date.getSeconds()).padStart(2, '0');
            return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
        }

        function getStatusBadge(status) {
            const statusMap = {
                'COMPLETED': { text: '已完成', class: 'bg-green-100 text-green-800' },
                'PENDING': { text: '待处理', class: 'bg-yellow-100 text-yellow-800' },
                'CANCELLED': { text: '已取消', class: 'bg-red-100 text-red-800' }
            };
            const s = statusMap[status] || { text: status, class: 'bg-gray-100 text-gray-800' };
            return `<span class="px-3 py-1 rounded-full text-xs font-bold ${s.class}">${s.text}</span>`;
        }

        function toggleOrderDetails(orderId) {
            const detailsEl = document.getElementById(`order-details-${orderId}`);
            const iconEl = document.getElementById(`toggle-icon-${orderId}`);
            
            if (detailsEl.classList.contains('hidden')) {
                detailsEl.classList.remove('hidden');
                iconEl.classList.remove('fa-chevron-down');
                iconEl.classList.add('fa-chevron-up');
            } else {
                detailsEl.classList.add('hidden');
                iconEl.classList.remove('fa-chevron-up');
                iconEl.classList.add('fa-chevron-down');
            }
        }

        async function loadOrders() {
            try {
                const res = await fetch('/api/orders');
                if (res.status === 401) {
                    Swal.fire({
                        icon: 'warning',
                        title: '请先登录',
                        text: '您需要登录后才能查看订单',
                        confirmButtonColor: '#4f46e5'
                    }).then(() => {
                        window.location.href = 'login.jsp';
                    });
                    return;
                }
                if (!res.ok) {
                    throw new Error('Failed to load orders');
                }

                const orders = await res.json();
                const ordersListEl = document.getElementById('ordersList');
                const emptyStateEl = document.getElementById('emptyState');
                const loadingEl = document.getElementById('loading');

                loadingEl.classList.add('hidden');

                if (orders.length === 0) {
                    emptyStateEl.classList.remove('hidden');
                    return;
                }

                ordersListEl.innerHTML = orders.map(order => {
                    const itemsCount = order.items ? order.items.length : 0;
                    return `
                        <div class="border border-gray-200 rounded-xl overflow-hidden shadow-sm hover:shadow-md transition-shadow">
                            <!-- Order Header -->
                            <div class="bg-gray-50 px-6 py-4 cursor-pointer hover:bg-gray-100 transition-colors" onclick="toggleOrderDetails(${order.id})">
                                <div class="flex flex-wrap items-center justify-between gap-4">
                                    <div class="flex flex-wrap items-center gap-4">
                                        <div>
                                            <span class="text-sm text-gray-500">订单号</span>
                                            <p class="font-bold text-gray-800">#${order.id}</p>
                                        </div>
                                        <div class="h-8 w-px bg-gray-300 hidden sm:block"></div>
                                        <div>
                                            <span class="text-sm text-gray-500">下单时间</span>
                                            <p class="font-medium text-gray-700">${formatDate(order.createdAt)}</p>
                                        </div>
                                        <div class="h-8 w-px bg-gray-300 hidden sm:block"></div>
                                        <div>
                                            <span class="text-sm text-gray-500">订单状态</span>
                                            <p class="mt-1">${getStatusBadge(order.status)}</p>
                                        </div>
                                    </div>
                                    <div class="flex items-center gap-4">
                                        <div class="text-end">
                                            <span class="text-sm text-gray-500">订单金额</span>
                                            <p class="text-xl font-bold text-indigo-600">${formatPrice(order.totalAmount)}</p>
                                        </div>
                                        <i id="toggle-icon-${order.id}" class="fas fa-chevron-down text-gray-400 transition-transform"></i>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Order Details -->
                            <div id="order-details-${order.id}" class="hidden border-t border-gray-200">
                                <div class="p-6">
                                    <h4 class="font-semibold text-gray-700 mb-4">
                                        <i class="fas fa-book me-2 text-indigo-500"></i>
                                        商品明细（共 ${itemsCount} 件）
                                    </h4>
                                    <div class="overflow-x-auto">
                                        <table class="table table-hover align-middle">
                                            <thead class="bg-gray-50 text-gray-600 text-sm">
                                                <tr>
                                                    <th class="py-3 px-4">图书信息</th>
                                                    <th class="py-3 px-4 text-center">单价</th>
                                                    <th class="py-3 px-4 text-center">数量</th>
                                                    <th class="py-3 px-4 text-end">小计</th>
                                                </tr>
                                            </thead>
                                            <tbody class="text-sm divide-y divide-gray-200">
                                                ${order.items ? order.items.map(item => `
                                                    <tr class="hover:bg-gray-50">
                                                        <td class="py-4 px-4">
                                                            <div class="flex items-center gap-3">
                                                                <img src="${item.book.imageUrl}" alt="${item.book.title}" 
                                                                     class="w-16 h-20 object-cover rounded shadow-sm">
                                                                <div>
                                                                    <p class="font-bold text-gray-800">${item.book.title}</p>
                                                                    <p class="text-xs text-gray-500">${item.book.author}</p>
                                                                </div>
                                                            </div>
                                                        </td>
                                                        <td class="py-4 px-4 text-center text-indigo-600 font-semibold">
                                                            ${formatPrice(item.price)}
                                                        </td>
                                                        <td class="py-4 px-4 text-center">
                                                            <span class="bg-gray-100 px-3 py-1 rounded-full text-xs font-bold">
                                                                ${item.quantity}
                                                            </span>
                                                        </td>
                                                        <td class="py-4 px-4 text-end font-bold text-gray-800">
                                                            ${formatPrice(item.price * item.quantity)}
                                                        </td>
                                                    </tr>
                                                `).join('') : ''}
                                            </tbody>
                                        </table>
                                    </div>
                                    <div class="flex justify-end mt-4 pt-4 border-t border-gray-200">
                                        <div class="text-right">
                                            <span class="text-gray-500">订单总计：</span>
                                            <span class="text-2xl font-bold text-indigo-600 ml-2">${formatPrice(order.totalAmount)}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;
                }).join('');

                ordersListEl.classList.remove('hidden');

            } catch (err) {
                console.error(err);
                document.getElementById('loading').classList.add('hidden');
                Swal.fire({
                    icon: 'error',
                    title: '加载失败',
                    text: '加载订单数据时出现错误，请稍后重试',
                    confirmButtonColor: '#ef4444'
                });
            }
        }

        loadOrders();
    </script>
</body>
</html>
