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
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});

		// 页面加载完毕后，展现该市场活动关联的备注信息列表
		showRemarkList();

		$("#remarkBody").on("mouseover", ".remarkDiv", function () {
            $(this).children("div").children("div").show();
        });
		$("#remarkBody").on("mouseout", ".remarkDiv", function () {
            $(this).children("div").children("div").hide();
        });

        $("#remarkBody").on("mouseover", ".myHref", function () {
            $(this).children("span").css("color","red");
        });
        $("#remarkBody").on("mouseout", ".myHref", function () {
            $(this).children("span").css("color","#E6E6E6");
        });

        // 为保存按钮绑定事件
        $("#saveRemarkBtn").click(function () {
            var html = "";

            $.ajax({
                url : "workbench/activity/saveRemark.do",
                data : {
                    "noteContent" : $.trim($("#remark").val()),
                    "activityId" : "${activity.id}"
                },
                type : "post",
                dataType : "json",
                success : function (data) {

                    /*
                        data:
                            {"success":true/false, "ActivityRemark":activityRemark}
                     */
                    if (data.success) {
                        $("#remark").val("");

                        html += ' <div id="' + data.ActivityRemark.id + '" class="remarkDiv" style="height: 60px;"> ';
                        html += ' 	<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;"> ';
                        html += ' 		<div style="position: relative; top: -40px; left: 40px;" > ';
                        html += ' 			<h5 id="contentId' + data.ActivityRemark.id + '">' + data.ActivityRemark.noteContent + '</h5> ';
                        html += ' 			<font color="gray">市场活动</font> <font color="gray">-</font> <b>${activity.name}</b> <small style="color: gray;" id="info' + data.ActivityRemark.id + '">' + data.ActivityRemark.createTime + ' 由' + data.ActivityRemark.createBy + '</small>';
                        html += ' 			<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;"> ';
                        html += ' 				<a class="myHref" href="javascript:void(0);" onclick="editRemark(\'' + data.ActivityRemark.id + '\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a> ';
                        html += ' 				&nbsp;&nbsp;&nbsp;&nbsp; ';
                        html += ' 				<a class="myHref" href="javascript:void(0);" onclick="removeRemark(\'' + data.ActivityRemark.id + '\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a> ';
                        html += ' 			</div> ';
                        html += ' 		</div> ';
                        html += ' </div> ';

                        $("#remarkDiv").before(html);
                    }else {
                        alert("备注添加失败")
                    }
                }
            })
        });

        $("#updateRemarkBtn").click(function () {
            var id = $("#remarkId").val();
            $.ajax({
                url : "workbench/activity/editRemark.do",
                data : {
                    "id" : id,
                    "noteContent" : $.trim($("#noteContent").val())
                },
                type : "post",
                dataType : "json",
                success : function (data) {
                    /*
                        data:
                            {"success":true/false,"activityRemark": ? }
                     */

                    if (data.success) {
                        $("#contentId" + id).html(data.ActivityRemark.noteContent);
                        $("#info" + id).html(data.ActivityRemark.editTime + " 由" + data.ActivityRemark.editBy);
                        $("#editRemarkModal").modal("hide");
                    }else {
                        alert("修改备注失败！")
                    }
                }
            });
        });

        // 为编辑按钮绑定事件
        $("#editActivityBtn").click(function() {
            var activityId = "${activity.id}";
            $.ajax({
                url : "workbench/activity/getUserListAndActivity.do",
                data : {
                    "id" : activityId
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
        });

        // 为更新按钮绑定事件
        $("#updateActivityBtn").click(function() {
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
                        $("#editActivityModal").modal("hide");
                        window.location.href="workbench/activity/detail.do?id=" + $.trim($("#edit-id").val());
                    }else {
                        alert("市场活动修改失败！");
                    }
                }
            });
        });

        // 为删除按钮绑定事件
        $("#deleteActivityBtn").click(function() {
            if (confirm("确定删除选中的活动吗？")) {
                var activityId = "${activity.id}";

                $.ajax({
                    url : "workbench/activity/delete.do",
                    data : {
                        "id" : activityId
                    },
                    type : "post",
                    dataType : "json",
                    success : function (data) {
                        // data {"success":true/false}
                        if (data.success) {
                            window.location.href = "workbench/index.jsp";
                        }else {
                            alert("删除市场活动失败！");
                        }
                    }
                });
            }
        });

	});


	function editRemark(id) {
	    $("#remarkId").val(id);

        var noteContent = $("#contentId" + id).html();
        $("#noteContent").val(noteContent);

        $("#editRemarkModal").modal("show");
    }

	function showRemarkList() {
		$.ajax({
			url : "workbench/activity/getRemarkListByActivityId.do",
			data : {
				"activityId" : "${activity.id}"
			},
			type : "get",
			dataType : "json",
			success : function (data) {
				/*
					data
						[{备注1},{备注2},{备注3},……]
				 */
				var html = "";
				$.each(data, function (i, n) {
					html += ' <div id="' + n.id + '" class="remarkDiv" style="height: 60px;"> ';
					html += ' 	<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;"> ';
					html += ' 		<div style="position: relative; top: -40px; left: 40px;" > ';
					html += ' 			<h5 id="contentId' + n.id + '">' + n.noteContent + '</h5> ';
					html += ' 			<font color="gray">市场活动</font> <font color="gray">-</font> <b>${activity.name}</b> <small style="color: gray;" id="info'+ n.id + '">' + (n.editFlag == 0 ? n.createTime : n.editTime) + ' 由' + (n.editFlag == 0 ? n.createBy : n.editBy) + '</small> ';
					html += ' 			<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;"> ';
					html += ' 				<a class="myHref" href="javascript:void(0);" onclick="editRemark(\'' + n.id + '\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a> ';
					html += ' 				&nbsp;&nbsp;&nbsp;&nbsp; ';
					html += ' 				<a class="myHref" href="javascript:void(0);" onclick="removeRemark(\'' + n.id + '\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a> ';
					html += ' 			</div> ';
					html += ' 		</div> ';
					html += ' </div> ';

                    /*<div class="remarkDiv" style="height: 60px;">
                        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
                            <div style="position: relative; top: -40px; left: 40px;" >
                                <h5>哎呦！</h5>
                                <font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
                                <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                                    <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
                                    &nbsp;&nbsp;&nbsp;&nbsp;
                                    <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
                                </div>
                            </div>
                    </div>*/
				})

				$("#remarkDiv").before(html);
			}
		})
	}

    function removeRemark(id) {
	    if (confirm("确认删除此备注？")) {
            $.ajax({
                url : "workbench/activity/removeRemark.do",
                data : {
                    "remarkId" : id
                },
                type : "get",
                dataType : "json",
                success : function (data) {
                    /*
                        data:
                            {"success":true/false}
                     */
                    if (data.success) {
                        // showRemarkList(); 记录使用的是before()方法，没有重新加载
                        $("#" + id).remove();

                    }else {
                        alert("删除备注信息失败！")
                    }
                }
            });
        }
    }
	
</script>

</head>
<body>
	
	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
        <div class="modal-dialog" role="document" style="width: 40%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myRemarkModalLabel">修改备注</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" role="form">
                        <div class="form-group">
                            <label for="edit-describe" class="col-sm-2 control-label">内容</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="noteContent"></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
                </div>
            </div>
        </div>
    </div>

    <!-- 修改市场活动的模态窗口 -->
    <div class="modal fade" id="editActivityModal" role="dialog">
        <input type="hidden" id="edit-id">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myActivityModalLabel">修改市场活动</h4>
                </div>
                <div class="modal-body">

                    <form class="form-horizontal" role="form">

                        <div class="form-group">
                            <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <select class="form-control" id="edit-marketActivityOwner">

                                </select>
                            </div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" >
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-startTime" >
                            </div>
                            <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-endTime" >
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
                                <textarea class="form-control" rows="3" id="edit-describe"></textarea>
                            </div>
                        </div>

                    </form>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="updateActivityBtn">更新</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>市场活动-${activity.name} <small>${activity.startDate} ~ ${activity.endDate}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" id="editActivityBtn"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" id="deleteActivityBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.startDate}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.endDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.cost}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${activity.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div id="remarkBody" style="position: relative; top: 30px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<%--<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<!-- 备注2 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveRemarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>
	<div style="height: 200px;"></div>
</body>
</html>