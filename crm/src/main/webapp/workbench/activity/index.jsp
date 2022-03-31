<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>

<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>




<script type="text/javascript">

	$(function(){

		$("#addBtn").click(function () {
			$(".time").datetimepicker({
				minView: "month",
				language: 'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});

			$.ajax({
				url : "workbench/activity/getUserList.do",
				type : "get",
				dataType : "json",
				success : function (data) {
					var html = "";
					// 遍历出来的每一个n，就是每一个user对象
					$.each(data, function (i, n) {
						html += "<option value='" + n.id + "'>" + n.name + "</option>"
					})
					$("#create-marketActivityOwner").html(html);

					// 将当前登录的用户设置为下拉框默认的选项
					// 注意：在js中使用EL表达式，EL表达式一定要套用在字符串中
					$("#create-marketActivityOwner").val("${user.id}");
					$("#createActivityModal").modal("show");
				}
			})

		})

		$("#saveBtn").click(function () {
			$.ajax({
				url : "workbench/activity/saveActivity.do",
				data : {
					"owner" : $.trim($("#create-marketActivityOwner").val()),
					"name" : $.trim($("#create-marketActivityName").val()),
					"startDate" : $.trim($("#create-startTime").val()),
					"endDate" : $.trim($("#create-endTime").val()),
					"cost" : $.trim($("#create-cost").val()),
					"description" : $.trim($("#create-describe").val())
				},
				type : "post",
				dataType : "json",
				success : function (data) {
					/*
						data
							{"success" : true/false}
					 */
					if (data.success) {

						/*
							pageList($("#activityPage").bs_pagination('getOption', 'currentPage')
								,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
						*/

						pageList(1, $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
						// 清空模态窗口的数据 【注意！对于表单的JQuery对象，提供了submit()方法用来提交表单，
						// 没有提供reset()方法来重置表单，该方法无效
						// 但是原生的js对象提供了reset()方法】
						/*
							jquery对象转换为dom对象：
								jqueryObject[index]
							dom对象转换为jquery对象：
								$(dom)
						 */
						$("#addActivityForm")[0].reset();
						//pageList(1, 2);
						$("#createActivityModal").modal("hide");

					}else {
						alert("市场活动添加失败！");
					}
				}
			});
		});

		// 页面加载完毕后，局部刷新市场活动列表
		pageList(1, 5);

		$("#search-activityBtn").click(function () {
			/*
				每次点击查询按钮时，我们应该把搜索框的内容保存起来
			 */
			$("#hidden-name").val($.trim($("#search-activityName").val()))
			$("#hidden-owner").val($.trim($("#search-activityOwner").val()))
			$("#hidden-startDate").val($.trim($("#search-activityStartTime").val()))
			$("#hidden-endDate").val($.trim($("#search-activityEndTime").val()))

			pageList(1, $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
		});

		// 为全选的复选框绑定事件，触发全选操作
		$("#activitySelectAll").click(function () {
			$("input[name=singleCheckBox]").prop("checked", this.checked);
		});

		// 动态生成的元素，是不能够以普通绑定事件的形式来进行操作的
		/*
		 	动态生成的元素，我们要以on方法的形式来触发事件
		 	语法：
		 		$(需要绑定元素的有效的外层元素).on(绑定事件的方式, 需要绑定的元素的jquery对象， 回调函数)
		 */
		$("#activityBody").on("click", $("input[name=singleCheckBox]"), function () {
			$("#activitySelectAll").prop("checked", $("input[name=singleCheckBox]").length == $("input[name=singleCheckBox]:checked").length)
		});

		// 为删除按钮绑定事件，执行市场活动删除操作
		$("#deleteBtn").click(function () {

			var $singleCheckBox = $("input[name=singleCheckBox]:checked");
			if ($singleCheckBox.length == 0) {
				alert("请选择需要删除的记录")
			}else {
				if (confirm("确定删除选中的活动吗？")) {
					var param = "";
					for (var i = 0; i < $singleCheckBox.length; i++) {
						if (i < $singleCheckBox.length - 1) param += "id=" + $singleCheckBox[i].value + "&";
						else param += "id=" + $singleCheckBox[i].value;
					}

					$.ajax({
						url : "workbench/activity/delete.do",
						data : param,
						type : "post",
						dataType : "json",
						success : function (data) {
							// data {"success":true/false}
							if (data.success) {
								pageList(1, $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
							}else {
								alert("删除市场活动失败！");
							}
						}
					});
				}
			}
		});

		// 为修改按钮绑定事件，打开修改操作的模态窗口
		$("#editBtn").click(function () {
			var $selected = $("input[name=singleCheckBox]:checked");
			if ($selected.length == 0) {
				alert("请选择需要修改的记录");
			}else if ($selected.length > 1) {
				alert("请选择一条记录")
			}else {
				var id = $selected.val();

				$.ajax({
					url : "workbench/activity/getUserListAndActivity.do",
					data : {
						"id" : id
					},
					type : "get",
					dataType : "json",
					success : function (data) {
						/*
							data
								用户列表
								市场活动对象
								{"uList":[{用户1},{用户2},{用户3},……],"activity":{市场活动}}
						 */
						var html = "";
						
						$.each(data.uList, function (i, n) {
							html += "<option value='" + n.id + "'>" + n.name + "</option>";
						})

						$("#edit-marketActivityOwner").html(html);

						$("#edit-marketActivityName").val(data.activity.name);
						$("#edit-marketActivityOwner").val(data.activity.owner);
						$("#edit-startTime").val(data.activity.startDate);
						$("#edit-endTime").val(data.activity.endDate);
						$("#edit-cost").val(data.activity.cost);
						$("#edit-describe").val(data.activity.description);
						$("#edit-id").val(data.activity.id);

						// 所有值处理好之后可以打开修改操作的模态窗口
						$("#editActivityModal").modal("show");

					}
				})
			}
		});

		// 为更新按钮绑定事件，执行市场活动的修改操作
		$("#updateBtn").click(function () {
			$.ajax({
				url : "workbench/activity/updateActivity.do",
				data : {
					"id" : $.trim($("#edit-id").val()),
					"owner" : $.trim($("#edit-marketActivityOwner").val()),
					"name" : $.trim($("#edit-marketActivityName").val()),
					"startDate" : $.trim($("#edit-startTime").val()),
					"endDate" : $.trim($("#edit-endTime").val()),
					"cost" : $.trim($("#edit-cost").val()),
					"description" : $.trim($("#edit-describe").val())
				},
				type : "post",
				dataType : "json",
				success : function (data) {
					/*
						data
							{"success" : true/false}
					 */
					if (data.success) {
						pageList($("#activityPage").bs_pagination('getOption', 'currentPage')
								,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
						$("#editActivityModal").modal("hide");

					}else {
						alert("市场活动修改失败！");
					}
				}
			});
		});


	});

	/*
		对于所有的关系型数据库，做前端的分页操作相关的基础组件
		就是pageNo和pageSize
		pageNo：页码
		pageSize：每页展现的记录数

		pageList()：就是发出ajax请求到后台，取得最新的市场活动信息列表数据
					通过响应回来的数据，局部刷新市场活动信息列表

		什么情况下需要调用pageList方法：
			（1）点击左侧菜单栏中的“市场活动”超链接
			（2）添加、修改、删除后
			（3）点击查询按钮饿时候
			（4）点击分页组件按钮时
	 */
	function pageList(pageNo, pageSize) {
		$("#activitySelectAll").prop("checked", false);
		// 查询前，将隐藏域中保存的信息取出来，重写赋予到搜索域中
		$("#search-activityName").val($.trim($("#hidden-name").val()))
		$("#search-activityOwner").val($.trim($("#hidden-owner").val()))
		$("#search-activityStartTime").val($.trim($("#hidden-startDate").val()))
		$("#search-activityEndTime").val($.trim($("#hidden-endDate").val()))

		$.ajax({
			url : "workbench/activity/pageList.do",
			data : {
				"pageNo" : pageNo,
				"pageSize" : pageSize,
				"name" : $.trim($("#search-activityName").val()),
				"owner" : $.trim($("#search-activityOwner").val()),
				"startDate" : $.trim($("#search-activityStartTime").val()),
				"endDate" : $.trim($("#search-activityEndTime").val())
			},
			type : "get",
			dataType : "json",
			success : function (data) {
				/*
					data
						我们需要的：
						[{市场活动列表1}, {市场活动列表2}， ……]
						分页插件需要的，查询出来的总记录数：
						{"total":100}

						{"total":100, "dataList":[{市场活动1}, {市场活动2}, ……]}
				 */

				var html = "";

				$.each(data.dataList, function (i, n) {
					html += ' <tr class="active"> ';
					html += ' 	<td><input type="checkbox" value="' + n.id + '" name="singleCheckBox"/></td> ';
					html += ' 	<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/activity/detail.do?id=' + n.id + '\';">' + n.name + '</a></td> ';
					html += ' 	<td>' + n.owner + '</td> ';
					html += ' 	<td>' + n.startDate + '</td> ';
					html += ' 	<td>' + n.endDate + '</td> ';
					html += ' </tr> ';
				})

				$("#activityBody").html(html);

				// 计算总页数
				var totalPages = Math.ceil(data.total / pageSize);

				// 数据处理完毕后，结合分页插件，对前端展现分页相关的信息
				$("#activityPage").bs_pagination({
					currentPage : pageNo, // 页码
					rowsPerPage : pageSize, // 每页显示的记录条数
					maxRowsPerPage : 20, // 每页最多显示的记录条数
					totalPages : totalPages, // 总页数
					totalRows : data.total, // 总记录数

					visiblePageLinks : 5, // 显示几个卡片

					showGoToPage : true,
					showRowsPerPage : true,
					showRowsInfo : true,
					showRowsDefaultInfo : true,

					// 在点击分页组件的时候出发的
					onChangePage : function (event, data) {
						pageList(data.currentPage, data.rowsPerPage);
					}
				});
			}
		});
	}
	
</script>
</head>
<body>

	<input type="hidden" id="hidden-name">
	<input type="hidden" id="hidden-owner">
	<input type="hidden" id="hidden-startDate">
	<input type="hidden" id="hidden-endDate">

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form id="addActivityForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">

								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-startTime" >
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-endTime" >
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">

						<input type="hidden" id="edit-id" />
					
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">

								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startTime" >
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-endTime" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<%--
									关于文本域textarea
										（1）一定要以标签对的形式来呈现，正常状态下标签对要紧紧挨着
										（2）textarea虽然是以标签对的形式来呈现的，但它也属于表单元素范畴，我们所有的对于textarea的取值和赋值操作，应该统一使用val()方法
								--%>
								<textarea class="form-control" rows="3" id="edit-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-activityName">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-activityOwner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="search-activityStartTime" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="search-activityEndTime">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="search-activityBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="activitySelectAll" /></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="activityBody">
						<%--<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">

				<div id="activityPage"></div>

			</div>
			
		</div>
		
	</div>
</body>
</html>