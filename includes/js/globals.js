function swapClassesForSyntaxHighlighting(a,b){for(var c in b){var d=new RegExp(b[c].pattern,"gi");if(a.html().match(d))return b[c].class}return"found"}$(document).ready(function(){$("pre code").each(function(){var a={tab:"&nbsp;&nbsp;&nbsp;&nbsp;"},b=$("<table>").addClass("syntax-highlighting").append($("<tr>").append($("<td>").addClass("gutter")).append($("<td>").addClass("code"))),c=[{"class":"string",pattern:"((?:\"|')[^\"']{0,}(?:\"|'))"},{"class":"regex",pattern:"(\\/[^\\/]+\\/[gim]{0,})"},{"class":"const",pattern:"(?:(var|new|function|private|if|else|for|in)\\s)"},{"class":"operator",pattern:"((?:[\\+\\-\\=\\!\\|\\:\\[\\]\\(\\)\\{\\}\\>\\<]|&amp;|&lt;|&gt;){1,}|(?:[^\\*\\/]\\/(?!\\/|\\*)))"},{"class":"comment",pattern:"\\/\\/[^\\(\\n|\\r)]+|\\/\\*|\\*\\/"}],d="";for(var e in c)d+=c[e].pattern+"|";d="("+d.replace(/\|$/,"")+")";for(var f=new RegExp(d,"gi"),g=$(this).html().split(/\r\n|\r|\n|<br(?:\s\/)?>/g),h=g.length-1,i=0;h>=i;i++){var j=g[i].replace(/\t/g,a.tab);j=j.replace(f,"<span class='found'>$1</span>"),j=$("<div>").html(j||"&nbsp;"),b.find("td.gutter").append($("<div>").html(i+1)),b.find("td.code").append(j)}b.find("td.code .found").each(function(){$(this).removeClass("found").addClass(swapClassesForSyntaxHighlighting($(this),c))}),$(this).closest("pre").replaceWith(b)}),$(".admin-btn").on("click",function(){$(this).children(".glyphicon").toggleClass("glyphicon-chevron-right").toggleClass("glyphicon-chevron-left"),$(".admin-menu").toggleClass("open"),$("body").toggleClass("admin-menu-open")})});