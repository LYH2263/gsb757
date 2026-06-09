<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
</head>
<body class="bg-gray-50 min-h-screen flex flex-col">

    <nav class="navbar navbar-expand-lg bg-white shadow-sm py-3 sticky-top">
        <div class="container">
            <a class="navbar-brand font-bold text-2xl text-indigo-600 flex items-center gap-2" href="index.jsp">
                <i class="fas fa-book-open"></i> 网上书店
            </a>
            <div class="d-flex gap-3">
                <a href="index.jsp" class="btn btn-outline-secondary rounded-full px-4 font-medium transition-all">
                    <i class="fas fa-home me-2"></i> 首页
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
                <i class="fas fa-box-open me-3 text-indigo-600"></i>我的订单
            </h2>

            <div id="ordersContainer">
                <div class="col-12 text-center py-10">
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
        function formatPrice(price) {
            return '¥' + Number(price).toFixed(2);
        }

        function formatDate(timestamp) {
            var date = new Date(timestamp);
            var year = date.getFullYear();
            var month = String(date.getMonth() + 1).padStart(2, '0');
            var day = String(date.getDate()).padStart(2, '0');
            var hours = String(date.getHours()).padStart(2, '0');
            var minutes = String(date.getMinutes()).padStart(2, '0');
            var seconds = String(date.getSeconds()).padStart(2, '0');
            return year + '-' + month + '-' + day + ' ' + hours + ':' + minutes + ':' + seconds;
        }

        function getStatusBadge(status) {
            var statusMap = {
                'COMPLETED': { text: '已完成', cls: 'bg-green-100 text-green-800' },
                'PENDING': { text: '待处理', cls: 'bg-yellow-100 text-yellow-800' },
                'CANCELLED': { text: '已取消', cls: 'bg-red-100 text-red-800' }
            };
            var info = statusMap[status] || { text: status, cls: 'bg-gray-100 text-gray-800' };
            return '<span class="px-3 py-1 rounded-full text-xs font-bold ' + info.cls + '">' + info.text + '</span>';
        }

        function toggleOrder(orderId) {
            var detailsEl = document.getElementById('details-' + orderId);
            var iconEl = document.getElementById('icon-' + orderId);
            
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

        function renderOrderItem(item) {
            var subtotal = Number(item.price) * item.quantity;
            var bookTitle = item.book ? item.book.title : '未知图书';
            var bookAuthor = item.book ? item.book.author : '';
            
            return '<tr class="border-t">' +
                '<td class="py-3 px-4">' +
                    '<div class="font-semibold text-gray-800">' + bookTitle + '</div>' +
                    '<div class="text-xs text-gray-400 mt-1">' + bookAuthor + '</div>' +
                '</td>' +
                '<td class="py-3 px-4 text-center text-indigo-600 font-medium">' + formatPrice(item.price) + '</td>' +
                '<td class="py-3 px-4 text-center">' +
                    '<span class="bg-gray-100 px-3 py-1 rounded-full text-xs font-bold">' + item.quantity + '</span>' +
                '</td>' +
                '<td class="py-3 px-4 text-end font-bold text-gray-800">' + formatPrice(subtotal) + '</td>' +
            '</tr>';
        }

        function renderOrder(order) {
            var itemsHtml = order.items.map(renderOrderItem).join('');
            
            return '<div class="border rounded-xl mb-4 overflow-hidden shadow-sm hover:shadow-md transition-shadow">' +
                '<div class="bg-gray-50 p-4 flex flex-wrap items-center justify-between cursor-pointer hover:bg-gray-100 transition-colors" onclick="toggleOrder(' + order.id + ')">' +
                    '<div class="flex flex-wrap items-center gap-4 md:gap-8">' +
                        '<div class="flex items-center gap-2">' +
                            '<i class="fas fa-hashtag text-indigo-600"></i>' +
                            '<span class="font-semibold text-gray-800">订单号: ' + order.id + '</span>' +
                        '</div>' +
                        '<div class="flex items-center gap-2 text-gray-600">' +
                            '<i class="fas fa-clock"></i>' +
                            '<span>' + formatDate(order.createdAt) + '</span>' +
                        '</div>' +
                        '<div class="flex items-center gap-2">' +
                            getStatusBadge(order.status) +
                        '</div>' +
                    '</div>' +
                    '<div class="flex items-center gap-4 mt-2 md:mt-0">' +
                        '<div class="text-lg font-bold text-indigo-600">' +
                            formatPrice(order.totalAmount) +
                        '</div>' +
                        '<button class="btn btn-sm btn-link text-gray-500 hover:text-indigo-600 p-2">' +
                            '<i id="icon-' + order.id + '" class="fas fa-chevron-down transition-transform"></i>' +
                        '</button>' +
                    '</div>' +
                '</div>' +
                '<div id="details-' + order.id + '" class="hidden">' +
                    '<div class="p-4 bg-white">' +
                        '<div class="table-responsive">' +
                            '<table class="table table-hover align-middle mb-0">' +
                                '<thead class="bg-gray-50 text-gray-600 text-sm">' +
                                    '<tr>' +
                                        '<th class="py-3 px-4 border-0">图书名称</th>' +
                                        '<th class="py-3 px-4 border-0 text-center">单价</th>' +
                                        '<th class="py-3 px-4 border-0 text-center">数量</th>' +
                                        '<th class="py-3 px-4 border-0 text-end">小计</th>' +
                                    '</tr>' +
                                '</thead>' +
                                '<tbody class="text-sm">' +
                                    itemsHtml +
                                '</tbody>' +
                                '<tfoot>' +
                                    '<tr class="border-t-2 border-gray-200">' +
                                        '<td colspan="3" class="py-3 px-4 text-end font-bold text-gray-700">订单总计:</td>' +
                                        '<td class="py-3 px-4 text-end font-bold text-xl text-indigo-600">' + formatPrice(order.totalAmount) + '</td>' +
                                    '</tr>' +
                                '</tfoot>' +
                            '</table>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
            '</div>';
        }

        async function loadOrders() {
            try {
                var res = await fetch('/api/orders');
                if (res.status === 401) {
                    window.location.href = 'login.jsp';
                    return;
                }
                var orders = await res.json();
                var container = document.getElementById('ordersContainer');

                if (orders.length === 0) {
                    container.innerHTML = 
                        '<div class="text-center py-16">' +
                            '<div class="inline-flex items-center justify-center w-24 h-24 rounded-full bg-gray-100 mb-6">' +
                                '<i class="fas fa-receipt text-5xl text-gray-300"></i>' +
                            '</div>' +
                            '<h3 class="text-xl font-semibold text-gray-700 mb-2">暂无订单记录</h3>' +
                            '<p class="text-gray-500 mb-6">快去挑选心仪的图书吧！</p>' +
                            '<a href="index.jsp" class="btn bg-indigo-600 text-white rounded-lg px-6 py-3 hover:bg-indigo-700 hover:shadow-lg transition-all inline-flex items-center">' +
                                '<i class="fas fa-book me-2"></i>去逛逛' +
                            '</a>' +
                        '</div>';
                    return;
                }

                container.innerHTML = orders.map(renderOrder).join('');

            } catch (err) {
                console.error(err);
                container.innerHTML = '<div class="text-center text-red-500 py-10"><i class="fas fa-exclamation-circle me-2"></i>加载订单失败</div>';
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
