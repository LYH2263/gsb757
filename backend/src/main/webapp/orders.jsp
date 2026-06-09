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
    <style>
        .order-card {
            transition: box-shadow 0.3s ease, transform 0.3s ease;
        }
        .order-card:hover {
            box-shadow: 0 10px 25px -5px rgba(0,0,0,0.1);
        }
        .chevron {
            transition: transform 0.3s ease;
        }
        .chevron.expanded {
            transform: rotate(180deg);
        }
        .details-wrapper {
            overflow: hidden;
            max-height: 0;
            transition: max-height 0.4s ease;
        }
        .details-wrapper.expanded {
            max-height: 2000px;
        }
        .status-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 700;
        }
    </style>
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
            <h2 class="text-3xl font-bold mb-6 text-gray-800 border-b pb-4 flex items-center gap-3">
                <i class="fas fa-receipt text-indigo-600"></i> 我的订单
            </h2>

            <div id="loading" class="text-center py-10">
                <div class="spinner-border text-indigo-600" role="status">
                    <span class="visually-hidden">加载中...</span>
                </div>
            </div>

            <div id="orderList" class="space-y-4 hidden"></div>

            <div id="emptyState" class="hidden text-center py-16">
                <div class="flex flex-col items-center">
                    <i class="fas fa-box-open text-6xl mb-4 text-gray-300"></i>
                    <h3 class="text-xl font-bold text-gray-700 mb-2">暂无订单</h3>
                    <p class="text-gray-500 mb-6">您还没有任何订单记录，快去挑选心仪的图书吧！</p>
                    <a href="index.jsp" class="btn btn-primary rounded-xl px-6 py-2 bg-indigo-600 hover:bg-indigo-700 border-none font-medium shadow-md">
                        <i class="fas fa-book me-2"></i> 去购物
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
        function formatPrice(amount) {
            const n = Number(amount);
            if (isNaN(n)) return '¥0.00';
            return '¥' + n.toFixed(2);
        }

        function escapeHtml(str) {
            if (str === null || str === undefined) return '';
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        function statusLabel(status) {
            const map = {
                'COMPLETED': { text: '已完成', cls: 'bg-green-100 text-green-700' },
                'PENDING':   { text: '待处理', cls: 'bg-yellow-100 text-yellow-700' },
                'SHIPPED':   { text: '已发货', cls: 'bg-blue-100 text-blue-700' },
                'CANCELLED': { text: '已取消', cls: 'bg-gray-200 text-gray-600' }
            };
            const s = map[status] || { text: status || '未知', cls: 'bg-gray-100 text-gray-600' };
            return '<span class="status-badge ' + s.cls + '">' + escapeHtml(s.text) + '</span>';
        }

        function renderItems(items) {
            if (!items || items.length === 0) {
                return '<div class="text-center text-gray-400 py-4">该订单暂无图书明细</div>';
            }
            const rows = items.map(it => {
                const title = it.book ? it.book.title : ('图书 #' + it.bookId);
                const price = Number(it.price);
                const subtotal = price * it.quantity;
                return (
                    '<tr class="hover:bg-gray-50">' +
                        '<td class="py-2 px-3 font-medium text-gray-800">' + escapeHtml(title) + '</td>' +
                        '<td class="py-2 px-3 text-indigo-600 font-semibold">' + formatPrice(price) + '</td>' +
                        '<td class="py-2 px-3"><span class="bg-gray-100 px-2 py-0.5 rounded-full text-xs font-bold">' + it.quantity + '</span></td>' +
                        '<td class="py-2 px-3 font-bold">' + formatPrice(subtotal) + '</td>' +
                    '</tr>'
                );
            }).join('');
            return (
                '<div class="table-responsive">' +
                    '<table class="table table-sm align-middle mb-0">' +
                        '<thead class="bg-gray-100 text-gray-600 uppercase text-xs tracking-wider">' +
                            '<tr>' +
                                '<th class="py-2 px-3">书名</th>' +
                                '<th class="py-2 px-3">单价</th>' +
                                '<th class="py-2 px-3">数量</th>' +
                                '<th class="py-2 px-3">小计</th>' +
                            '</tr>' +
                        '</thead>' +
                        '<tbody class="text-sm">' + rows + '</tbody>' +
                    '</table>' +
                '</div>'
            );
        }

        async function loadOrders() {
            try {
                const res = await fetch('/order/list', {
                    headers: { 'Accept': 'application/json' }
                });
                if (res.status === 401) {
                    window.location.href = 'login.jsp';
                    return;
                }
                if (!res.ok) {
                    throw new Error('请求失败：' + res.status);
                }
                const orders = await res.json();
                document.getElementById('loading').classList.add('hidden');

                if (!orders || orders.length === 0) {
                    document.getElementById('emptyState').classList.remove('hidden');
                    return;
                }

                const list = document.getElementById('orderList');
                list.classList.remove('hidden');
                list.innerHTML = orders.map(o => {
                    const itemCount = (o.items || []).reduce((s, it) => s + (it.quantity || 0), 0);
                    return (
                        '<div class="order-card border rounded-2xl bg-white">' +
                            '<div class="p-4 md:p-5 flex flex-col md:flex-row md:items-center md:justify-between gap-3 cursor-pointer" onclick="toggleOrder(' + o.id + ')">' +
                                '<div class="flex-1 grid grid-cols-2 md:grid-cols-4 gap-3 text-sm">' +
                                    '<div>' +
                                        '<div class="text-xs text-gray-400 mb-1">订单号</div>' +
                                        '<div class="font-bold text-gray-800">#' + o.id + '</div>' +
                                    '</div>' +
                                    '<div>' +
                                        '<div class="text-xs text-gray-400 mb-1">下单时间</div>' +
                                        '<div class="font-medium text-gray-700">' + escapeHtml(o.createdAt || '-') + '</div>' +
                                    '</div>' +
                                    '<div>' +
                                        '<div class="text-xs text-gray-400 mb-1">状态</div>' +
                                        '<div>' + statusLabel(o.status) + '</div>' +
                                    '</div>' +
                                    '<div>' +
                                        '<div class="text-xs text-gray-400 mb-1">订单总金额</div>' +
                                        '<div class="font-bold text-indigo-600 text-lg">' + formatPrice(o.totalAmount) + '</div>' +
                                    '</div>' +
                                '</div>' +
                                '<div class="flex items-center gap-3 md:ml-4 text-gray-500">' +
                                    '<span class="text-xs hidden md:inline">共 ' + itemCount + ' 件</span>' +
                                    '<button type="button" class="btn btn-sm btn-light rounded-full" aria-label="展开/收起">' +
                                        '<i id="chevron-' + o.id + '" class="fas fa-chevron-down chevron"></i>' +
                                    '</button>' +
                                '</div>' +
                            '</div>' +
                            '<div id="details-' + o.id + '" class="details-wrapper border-t bg-gray-50 px-4 md:px-5">' +
                                '<div class="py-4">' + renderItems(o.items) + '</div>' +
                            '</div>' +
                        '</div>'
                    );
                }).join('');
            } catch (err) {
                console.error(err);
                document.getElementById('loading').classList.add('hidden');
                Swal.fire({
                    icon: 'error',
                    title: '加载失败',
                    text: '无法获取订单列表，请稍后重试',
                    confirmButtonColor: '#4f46e5'
                });
            }
        }

        function toggleOrder(id) {
            const wrap = document.getElementById('details-' + id);
            const chev = document.getElementById('chevron-' + id);
            if (!wrap || !chev) return;
            wrap.classList.toggle('expanded');
            chev.classList.toggle('expanded');
        }

        loadOrders();
    </script>
</body>
</html>
