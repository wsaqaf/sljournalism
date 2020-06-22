// XThis is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require jquery
//= require jquery-ui
//= require popper
//= require tether
//= require bootstrap-sprockets
//= require jquery.turbolinks
//= require turbolinks
//= require react
//= require react_ujs
//= require components
//= require_tree .
//= require jquery-ui/widgets/autocomplete
//= require autocomplete-rails
//= require areyousure/jquery.are-you-sure.js
//= require chosen
//= require moment
//= require moment-timezone-with-data
//= require tempusdominus-bootstrap-4
//= require bootstrap-datepicker

jQuery(function() {
  $("#user_affiliation").autocomplete({
    source: $("#user_affiliation").data("autocomplete-source")
  });
});

var started_loading = 0;

function NewMedium(relative_url, c, s, p, w) {
  var element;
  if (c == 1) {
    element = document.getElementById("claim_" + s + "_name");
  } else {
    element = document.getElementById(s + "_name");
  }
  var q = element.value;
  q = $.trim(q);
  const note = document.getElementById(s + "_note");
  if (q.length == 0) {
    note.innerHTML = "";
    return;
  }
  started_loading = 1;
  $.ajax({
    url: relative_url + "/" + p + "/?term=" + q,
    cache: false
  }).done(function(html) {
    var found = false;
    var entry = "";
    for (var i = 0; i < html.length; i++) {
      if (html[i].toLowerCase() == q.toLowerCase()) {
        entry = html[i];
        found = true;
        break;
      }
    }
    if (found) {
      if (c == 1) {
        element.value = entry;
        note.innerHTML = "";
      } else {
        window.stop();
        note.innerHTML =
          "<b><font color=red>" +
          q +
          '</font></b> cannot be added because it is already in the database. You can find it by clicking on the <a href="/' +
          p +
          '" target=_blank>' +
          w +
          " page</a><br>";
        alert(
          q +
            " cannot be added because it is already in the database, even if not shared.\n\n You can try entering it again under a different name."
        );
        document.getElementById("submit").disabled = true;
        started_loading = 0;
      }
    } else {
      if (c == 1) {
        note.innerHTML =
          "<b><font color=red>" +
          q +
          "</font></b> is new and will be added automatically to the " +
          w +
          ' database. You can find it by clicking on the <a href="/' +
          p +
          '" target=_blank>' +
          w +
          " page</a> after submitting this form.<br><br>";
      } else {
        note.innerHTML = "";
        document.getElementById("submit").disabled = false;
        started_loading = 0;
      }
    }
  });
}
function do_submit(s) {
  if ($("#final_url_preview").html() != undefined) {
    if ($("#final_url_preview").html().length > 10) {
      $("#" + s + "_url_preview").val(
        '<br><div id="final_url_preview" class="fragment">' +
          addslashes($("#final_url_preview").html()) +
          "</div>"
      );
      $(+s + "_url_preview").val($("#final_url_preview").html());
      return false;
    }
  }
}

function submit_tags(relative_url, s) {
  $("#new_tags_block").html(
    "<br><center><img src='" +
      relative_url +
      "/assets/loading.gif' width=50></center><br>"
  );
  const element = document.getElementById(s + "_tag_list");
  var q = element.value;
  q = $.trim(q);
  if (q.length == 0) {
    $("#new_tags_block").html("");
    return;
  }
  $.ajax({
    url: relative_url + "/" + s + "s" + "/",
    type: "get",
    data: { tag_list: q },
    dataType: "text",
    success: function(result) {
      if (result.length > 0) {
        $("#new_tags_block").html(result);
        var new_list = "";
        $.ajax({
          url: relative_url + "/" + s + "s" + "/",
          type: "get",
          data: { refresh_tag_list: "1" },
          dataType: "text",
          success: function(result) {
            if (result.length > 0) {
              $("#" + s + "_tag_ids").html(result);
              if (typeof result2 !== "undefined") {
                if (result2.length > 0) {
                  var regexp = /\- (\w+) added/g;
                  var array1 = [...result2.matchAll(regexp)];
                  array1.forEach(function(element) {
                    $('select[id="' + s + '_tag_ids"]')
                      .find('option:contains("' + element[1] + '")')
                      .attr("selected", true);
                  });
                }
              }
              $("#" + s + "_tag_ids").trigger("chosen:updated");
            }
          }
        });
      } else {
        $("#new_tags_block").html(
          "<center><small>[Could not add tags]</small></center>"
        );
      }
    },
    error: function() {
      $("#new_tags_block").html(
        "<center><small>[Could not add tags]</small></center>"
      );
    }
  });
  return false;
}

function update_display(relative_url, s) {
  if ($("#skip_preview").is(":checked")) {
    $("#preview_block").hide();
    $("#url_preview_block").html("");
    $("#" + s + "_url_preview").val(" ");
  } else {
    $("#preview_block").show();
    URLPreview(relative_url, s);
  }
}
function addslashes(str) {
  return str;
}
function URLPreview(relative_url, s) {
  $("#url_preview_block").html(
    "<br><center><img src='" +
      relative_url +
      "/assets/loading.gif' width=50></center><br>"
  );
  const element = document.getElementById(s + "_url");
  var q = element.value;
  q = $.trim(q);
  if (q.length == 0) {
    $("#url_preview_block").html("");
    $("#" + s + "_url_preview").val(" ");
    return;
  }
  if (!q.toLowerCase().startsWith("http")) {
    q = "http://" + q;
    $("#" + s + "_url").val(q);
  }
  $.ajax({
    url: relative_url + "/claims/",
    type: "get",
    data: { url: q },
    dataType: "text",
    success: function(result) {
      if (result.length > 0) {
        $("#" + s + "_url_preview").val(addslashes(result));
        $("#url_preview_block").html(
          "<div id='preview_block'>" +
            result +
            "</div><input type='checkbox' id='skip_preview' value=1 onchange='update_display(\"" +
            relative_url +
            '","' +
            s +
            "\")'><small> Skip preview</small><br>"
        );
      } else {
        $("#" + s + "_url_preview").val(" ");
        $("#url_preview_block").html(
          "<center><small>[URL does not have a preview]</small></center>"
        );
      }
    },
    error: function() {
      $("#" + s + "_url_preview").val(" ");
      $("#url_preview_block").html(
        "<center><small>[URL does not have a preview]</small></center>"
      );
    }
  });
}

function ResponsiveMenu() {
  var x = document.getElementById("myTopnav");
  if (x.className === "topnav") {
    x.className += " responsive";
  } else {
    x.className = "topnav";
  }
}

function copyToClipboard(element) {
  var $temp = $("<input>");
  $("body").append($temp);
  $temp.val($(element).val()).select();
  document.execCommand("copy");
  $temp.remove();
}

function wallet(rel_url,url1,usr,to_add,add_to_blockchain)
 {
  var add_more="0";
  if (to_add === "1") { add_more=$("#addbalance"+usr).val(); }
  $("#wallet"+usr).html("<img src='"+rel_url+"/assets/loading.gif' width=50><br>");
  $.ajax(
   {
    url: url1,
    type: "get",
    dataType: "text",
    data: { "getbalance": "1", "addtobalance": add_more, "add_to_blockchain": add_to_blockchain },
    success: function(result)
      {
        if (result.length > 0)
          {
            $("#wallet"+usr).html(result+" ");
            $("#hidden"+usr).show();
          }
      }
   });
}

function assess(rel_url,url1)
 {
  var assessment=$('#blockchain_assessment option:selected').val()
  var rationale=$('textarea#assessment_rationale').val();
  $("#assessment").html("<img src='"+rel_url+"/assets/loading.gif' width=50><br>");
  $.ajax(
   {
    url: url1,
    type: "get",
    dataType: "text",
    data: { "blockchain_assessment": assessment, "blockchain_assessment_rationale": rationale },
    success: function(result)
      {
        if (result.length > 0)
          {
            $("#assessment").html(result+" ");
            $("#assessment_div").hide();
          }
      }
   });
}
