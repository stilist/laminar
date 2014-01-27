(function(){function t(t){function n(t){t+="";var e=t.split(":"),n=~t.indexOf("-")?-1:1,s=Math.abs(+e[0]),r=parseInt(e[1],10)||0,i=parseInt(e[2],10)||0;return n*(60*s+r+i/60)}function s(t,e,s,r,i,u,a,o,h,f){this.name=t,this.startYear=+e,this.endYear=+s,this.month=+r,this.day=+i,this.dayRule=+u,this.time=n(a),this.timeRule=+o,this.offset=n(h),this.letters=f||""}function r(t,e){this.rule=e,this.start=e.start(t)}function i(t,e){return t.isLast?-1:e.isLast?1:e.start-t.start}function u(t){this.name=t,this.rules=[]}function a(e,s,r,i,u,a){var o,h="string"==typeof u?u.split("_"):[9999];for(this.name=e,this.offset=n(s),this.ruleSet=r,this.letters=i,o=0;h.length>o;o++)h[o]=+h[o];this.until=t.utc(h).subtract("m",n(a))}function o(t,e){return t.until-e.until}function h(t){this.name=d(t),this.displayName=t,this.zones=[]}function f(t){var e,n,s;for(e in t)for(s=t[e],n=0;s.length>n;n++)l(e+"	"+s[n])}function l(t){if(g[t])return g[t];var e=t.split(/\s/),n=d(e[0]),r=new s(n,e[1],e[2],e[3],e[4],e[5],e[6],e[7],e[8],e[9],e[10]);return g[t]=r,z(n).add(r),r}function d(t){return(t||"").toLowerCase().replace(/\//g,"_")}function c(t){var e,n,s;for(e in t)for(s=t[e],n=0;s.length>n;n++)p(e+"	"+s[n])}function m(t){var e;for(e in t)A[d(e)]=d(t[e])}function p(t){if(b[t])return b[t];var e=t.split(/\s/),n=d(e[0]),s=new a(n,e[1],z(e[2]),e[3],e[4],e[5]);return b[t]=s,y(e[0]).add(s),s}function z(t){return t=d(t),Y[t]||(Y[t]=new u(t)),Y[t]}function y(t){var e=d(t);return A[e]&&(e=A[e]),M[e]||(M[e]=new h(t)),M[e]}function v(t){t&&(t.zones&&c(t.zones),t.rules&&f(t.rules),t.links&&m(t.links))}var R,w=t.fn.zoneName,_=t.fn.zoneAbbr,g={},Y={},b={},M={},A={},k=1,L=2,N=7,q=8;return s.prototype={contains:function(t){return t>=this.startYear&&this.endYear>=t},start:function(e){return e=Math.min(Math.max(e,this.startYear),this.endYear),t.utc([e,this.month,this.date(e),0,this.time])},date:function(t){return this.dayRule===N?this.day:this.dayRule===q?this.lastWeekday(t):this.weekdayAfter(t)},weekdayAfter:function(e){for(var n=this.day,s=t([e,this.month,1]).day(),r=this.dayRule+1-s;n>r;)r+=7;return r},lastWeekday:function(e){var n=this.day,s=n%7,r=t([e,this.month+1,1]).day(),i=t([e,this.month,1]).daysInMonth(),u=i+(s-(r-1))-7*~~(n/7);return s>=r&&(u-=7),u}},r.prototype={equals:function(t){return t&&t.rule===this.rule?864e5>Math.abs(t.start-this.start):!1}},u.prototype={add:function(t){this.rules.push(t)},ruleYears:function(t,e){var n,s,u,a=t.year(),o=[];for(n=0;this.rules.length>n;n++)s=this.rules[n],s.contains(a)?o.push(new r(a,s)):s.contains(a+1)&&o.push(new r(a+1,s));return o.push(new r(a-1,this.lastYearRule(a-1))),e&&(u=new r(a-1,e.lastRule()),u.start=e.until.clone().utc(),u.isLast=e.ruleSet!==this,o.push(u)),o.sort(i),o},rule:function(t,e,n){var s,r,i,u,a,o=this.ruleYears(t,n),h=0;for(n&&(r=n.offset+n.lastRule().offset,i=9e4*Math.abs(r)),a=o.length-1;a>-1;a--)u=s,s=o[a],s.equals(u)||(n&&!s.isLast&&i>=Math.abs(s.start-n.until)&&(h+=r-e),s.rule.timeRule===L&&(h=e),s.rule.timeRule!==k&&s.start.add("m",-h),h=s.rule.offset+e);for(a=0;o.length>a;a++)if(s=o[a],t>=s.start&&!s.isLast)return s.rule;return R},lastYearRule:function(t){var e,n,s,r=R,i=-1e30;for(e=0;this.rules.length>e;e++)n=this.rules[e],t>=n.startYear&&(s=n.start(t),s>i&&(i=s,r=n));return r}},a.prototype={rule:function(t,e){return this.ruleSet.rule(t,this.offset,e)},lastRule:function(){return this._lastRule||(this._lastRule=this.rule(this.until)),this._lastRule},format:function(t){return this.letters.replace("%s",t.letters)}},h.prototype={zoneAndRule:function(t){var e,n,s;for(t=t.clone().utc(),e=0;this.zones.length>e&&(n=this.zones[e],!(n.until>t));e++)s=n;return[n,n.rule(t,s)]},add:function(t){this.zones.push(t),this.zones.sort(o)},format:function(t){var e=this.zoneAndRule(t);return e[0].format(e[1])},offset:function(t){var e=this.zoneAndRule(t);return-(e[0].offset+e[1].offset)}},t.updateOffset=function(t){var e;t._z&&(e=t._z.offset(t),16>Math.abs(e)&&(e/=60),t.zone(e))},t.fn.tz=function(e){return e?(this._z=y(e),this._z&&t.updateOffset(this),this):this._z?this._z.displayName:void 0},t.fn.zoneName=function(){return this._z?this._z.format(this):w.call(this)},t.fn.zoneAbbr=function(){return this._z?this._z.format(this):_.call(this)},t.tz=function(){var e,n=[],s=arguments.length-1;for(e=0;s>e;e++)n[e]=arguments[e];return t.apply(null,n).tz(arguments[s])},t.tz.add=v,t.tz.addRule=l,t.tz.addZone=p,t.tz.version=e,R=l("- 0 9999 0 0 0 0 0 0"),t}var e="0.0.1";"function"==typeof define&&define.amd?define("moment-timezone",["moment"],t):"undefined"!=typeof window&&window.moment?t(window.moment):"undefined"!=typeof module&&(module.exports=t(require("./moment")))}).apply(this);

moment.tz.add({
	"zones": {
		"Africa/Johannesburg": [
			"1:52 - LMT 1892_1_8 1:52",
			"1:30 - SAST 1903_2 1:30",
			"2 SA SAST"
		],
		"America/Anchorage": [
			"14:0:24 - LMT 1867_9_18 14:0:24",
			"-9:59:36 - LMT 1900_7_20_12 -9:59:36",
			"-10 - CAT 1942 -10",
			"-10 US CAT/CAWT 1945_7_14_23",
			"-10 US CAT/CAPT 1946 -10",
			"-10 - CAT 1967_3 -10",
			"-10 - AHST 1969 -10",
			"-10 US AH%sT 1983_9_30_2 -9",
			"-9 US Y%sT 1983_10_30 -9",
			"-9 US AK%sT"
		],
		"America/Argentina/Buenos_Aires": [
			"-3:53:48 - LMT 1894_9_31 -3:53:48",
			"-4:16:48 - CMT 1920_4 -4:16:48",
			"-4 - ART 1930_11 -4",
			"-4 Arg AR%sT 1969_9_5 -4",
			"-3 Arg AR%sT 1999_9_3 -3",
			"-4 Arg AR%sT 2000_2_3 -3",
			"-3 Arg AR%sT"
		],
		"America/Chicago": [
			"-5:50:36 - LMT 1883_10_18_12_9_24 -5:50:36",
			"-6 US C%sT 1920 -6",
			"-6 Chicago C%sT 1936_2_1_2 -6",
			"-5 - EST 1936_10_15_2 -5",
			"-6 Chicago C%sT 1942 -6",
			"-6 US C%sT 1946 -6",
			"-6 Chicago C%sT 1967 -6",
			"-6 US C%sT"
		],
		"America/Denver": [
			"-6:59:56 - LMT 1883_10_18_12_0_4 -6:59:56",
			"-7 US M%sT 1920 -7",
			"-7 Denver M%sT 1942 -7",
			"-7 US M%sT 1946 -7",
			"-7 Denver M%sT 1967 -7",
			"-7 US M%sT"
		],
		"America/Los_Angeles": [
			"-7:52:58 - LMT 1883_10_18_12_7_2 -7:52:58",
			"-8 US P%sT 1946 -8",
			"-8 CA P%sT 1967 -8",
			"-8 US P%sT"
		],
		"America/New_York": [
			"-4:56:2 - LMT 1883_10_18_12_3_58 -4:56:2",
			"-5 US E%sT 1920 -5",
			"-5 NYC E%sT 1942 -5",
			"-5 US E%sT 1946 -5",
			"-5 NYC E%sT 1967 -5",
			"-5 US E%sT"
		],
		"America/Phoenix": [
			"-7:28:18 - LMT 1883_10_18_11_31_42 -7:28:18",
			"-7 US M%sT 1944_0_1_00_1 -6",
			"-7 - MST 1944_3_1_00_1 -7",
			"-7 US M%sT 1944_9_1_00_1 -6",
			"-7 - MST 1967 -7",
			"-7 US M%sT 1968_2_21 -7",
			"-7 - MST"
		],
		"Asia/Baghdad": [
			"2:57:40 - LMT 1890 2:57:40",
			"2:57:36 - BMT 1918 2:57:36",
			"3 - AST 1982_4 3",
			"3 Iraq A%sT"
		],
		"Asia/Dubai": [
			"3:41:12 - LMT 1920 3:41:12",
			"4 - GST"
		],
		"Asia/Jakarta": [
			"7:7:12 - LMT 1867_7_10 7:7:12",
			"7:7:12 - JMT 1923_11_31_23_47_12 7:7:12",
			"7:20 - JAVT 1932_10 7:20",
			"7:30 - WIT 1942_2_23 7:30",
			"9 - JST 1945_8_23 9",
			"7:30 - WIT 1948_4 7:30",
			"8 - WIT 1950_4 8",
			"7:30 - WIT 1964 7:30",
			"7 - WIT"
		],
		"Asia/Kolkata": [
			"5:53:28 - LMT 1880 5:53:28",
			"5:53:20 - HMT 1941_9 5:53:20",
			"6:30 - BURT 1942_4_15 6:30",
			"5:30 - IST 1942_8 5:30",
			"6:30 - IST 1945_9_15 6:30",
			"5:30 - IST"
		],
		"Asia/Shanghai": [
			"8:5:57 - LMT 1928 8:5:57",
			"8 Shang C%sT 1949 8",
			"8 PRC C%sT"
		],
		"Asia/Tokyo": [
			"9:18:59 - LMT 1887_11_31_15",
			"9 - JST 1896 9",
			"9 - CJT 1938 9",
			"9 Japan J%sT"
		],
		"Australia/Sydney": [
			"10:4:52 - LMT 1895_1 10:4:52",
			"10 Aus EST 1971 10",
			"10 AN EST"
		],
		"Europe/Berlin": [
			"0:53:28 - LMT 1893_3 0:53:28",
			"1 C-Eur CE%sT 1945_4_24_2 2",
			"1 SovietZone CE%sT 1946 1",
			"1 Germany CE%sT 1980 1",
			"1 EU CE%sT"
		],
		"Europe/London": [
			"-0:1:15 - LMT 1847_11_1_0 -0:1:15",
			"0 GB-Eire %s 1968_9_27 1",
			"1 - BST 1971_9_31_2",
			"0 GB-Eire %s 1996",
			"0 EU GMT/BST"
		],
		"Europe/Moscow": [
			"2:30:20 - LMT 1880 2:30:20",
			"2:30 - MMT 1916_6_3 2:30",
			"2:30:48 Russia %s 1919_6_1_2 4:30:48",
			"3 Russia MSK/MSD 1922_9 3",
			"2 - EET 1930_5_21 2",
			"3 Russia MSK/MSD 1991_2_31_2 3",
			"2 Russia EE%sT 1992_0_19_2 2",
			"3 Russia MSK/MSD 2011_2_27_2 3",
			"4 - MSK"
		],
		"Pacific/Auckland": [
			"11:39:4 - LMT 1868_10_2 11:39:4",
			"11:30 NZ NZ%sT 1946_0_1 12",
			"12 NZ NZ%sT"
		],
		"Pacific/Honolulu": [
			"-10:31:26 - LMT 1896_0_13_12 -10:31:26",
			"-10:30 - HST 1933_3_30_2 -10:30",
			"-9:30 - HDT 1933_4_21_12 -9:30",
			"-10:30 - HST 1942_1_09_2 -10:30",
			"-9:30 - HDT 1945_8_30_2 -9:30",
			"-10:30 - HST 1947_5_8_2 -10:30",
			"-10 - HST"
		]
	},
	"rules": {
		"SA": [
			"1942 1943 8 15 0 2 0 1",
			"1943 1944 2 15 0 2 0 0"
		],
		"US": [
			"1918 1919 2 0 8 2 0 1 D",
			"1918 1919 9 0 8 2 0 0 S",
			"1942 1942 1 9 7 2 0 1 W",
			"1945 1945 7 14 7 23 1 1 P",
			"1945 1945 8 30 7 2 0 0 S",
			"1967 2006 9 0 8 2 0 0 S",
			"1967 1973 3 0 8 2 0 1 D",
			"1974 1974 0 6 7 2 0 1 D",
			"1975 1975 1 23 7 2 0 1 D",
			"1976 1986 3 0 8 2 0 1 D",
			"1987 2006 3 1 0 2 0 1 D",
			"2007 9999 2 8 0 2 0 1 D",
			"2007 9999 10 1 0 2 0 0 S"
		],
		"Arg": [
			"1930 1930 11 1 7 0 0 1 S",
			"1931 1931 3 1 7 0 0 0",
			"1931 1931 9 15 7 0 0 1 S",
			"1932 1940 2 1 7 0 0 0",
			"1932 1939 10 1 7 0 0 1 S",
			"1940 1940 6 1 7 0 0 1 S",
			"1941 1941 5 15 7 0 0 0",
			"1941 1941 9 15 7 0 0 1 S",
			"1943 1943 7 1 7 0 0 0",
			"1943 1943 9 15 7 0 0 1 S",
			"1946 1946 2 1 7 0 0 0",
			"1946 1946 9 1 7 0 0 1 S",
			"1963 1963 9 1 7 0 0 0",
			"1963 1963 11 15 7 0 0 1 S",
			"1964 1966 2 1 7 0 0 0",
			"1964 1966 9 15 7 0 0 1 S",
			"1967 1967 3 2 7 0 0 0",
			"1967 1968 9 1 0 0 0 1 S",
			"1968 1969 3 1 0 0 0 0",
			"1974 1974 0 23 7 0 0 1 S",
			"1974 1974 4 1 7 0 0 0",
			"1988 1988 11 1 7 0 0 1 S",
			"1989 1993 2 1 0 0 0 0",
			"1989 1992 9 15 0 0 0 1 S",
			"1999 1999 9 1 0 0 0 1 S",
			"2000 2000 2 3 7 0 0 0",
			"2007 2007 11 30 7 0 0 1 S",
			"2008 2009 2 15 0 0 0 0",
			"2008 2008 9 15 0 0 0 1 S"
		],
		"Chicago": [
			"1920 1920 5 13 7 2 0 1 D",
			"1920 1921 9 0 8 2 0 0 S",
			"1921 1921 2 0 8 2 0 1 D",
			"1922 1966 3 0 8 2 0 1 D",
			"1922 1954 8 0 8 2 0 0 S",
			"1955 1966 9 0 8 2 0 0 S"
		],
		"Denver": [
			"1920 1921 2 0 8 2 0 1 D",
			"1920 1920 9 0 8 2 0 0 S",
			"1921 1921 4 22 7 2 0 0 S",
			"1965 1966 3 0 8 2 0 1 D",
			"1965 1966 9 0 8 2 0 0 S"
		],
		"CA": [
			"1948 1948 2 14 7 2 0 1 D",
			"1949 1949 0 1 7 2 0 0 S",
			"1950 1966 3 0 8 2 0 1 D",
			"1950 1961 8 0 8 2 0 0 S",
			"1962 1966 9 0 8 2 0 0 S"
		],
		"NYC": [
			"1920 1920 2 0 8 2 0 1 D",
			"1920 1920 9 0 8 2 0 0 S",
			"1921 1966 3 0 8 2 0 1 D",
			"1921 1954 8 0 8 2 0 0 S",
			"1955 1966 9 0 8 2 0 0 S"
		],
		"Iraq": [
			"1982 1982 4 1 7 0 0 1 D",
			"1982 1984 9 1 7 0 0 0 S",
			"1983 1983 2 31 7 0 0 1 D",
			"1984 1985 3 1 7 0 0 1 D",
			"1985 1990 8 0 8 1 2 0 S",
			"1986 1990 2 0 8 1 2 1 D",
			"1991 2007 3 1 7 3 2 1 D",
			"1991 2007 9 1 7 3 2 0 S"
		],
		"Shang": [
			"1940 1940 5 3 7 0 0 1 D",
			"1940 1941 9 1 7 0 0 0 S",
			"1941 1941 2 16 7 0 0 1 D"
		],
		"PRC": [
			"1986 1986 4 4 7 0 0 1 D",
			"1986 1991 8 11 0 0 0 0 S",
			"1987 1991 3 10 0 0 0 1 D"
		],
		"Japan": [
			"1948 1948 4 1 0 2 0 1 D",
			"1948 1951 8 8 6 2 0 0 S",
			"1949 1949 3 1 0 2 0 1 D",
			"1950 1951 4 1 0 2 0 1 D"
		],
		"Aus": [
			"1917 1917 0 1 7 0:1 0 1",
			"1917 1917 2 25 7 2 0 0",
			"1942 1942 0 1 7 2 0 1",
			"1942 1942 2 29 7 2 0 0",
			"1942 1942 8 27 7 2 0 1",
			"1943 1944 2 0 8 2 0 0",
			"1943 1943 9 3 7 2 0 1"
		],
		"AN": [
			"1971 1985 9 0 8 2 2 1",
			"1972 1972 1 27 7 2 2 0",
			"1973 1981 2 1 0 2 2 0",
			"1982 1982 3 1 0 2 2 0",
			"1983 1985 2 1 0 2 2 0",
			"1986 1989 2 15 0 2 2 0",
			"1986 1986 9 19 7 2 2 1",
			"1987 1999 9 0 8 2 2 1",
			"1990 1995 2 1 0 2 2 0",
			"1996 2005 2 0 8 2 2 0",
			"2000 2000 7 0 8 2 2 1",
			"2001 2007 9 0 8 2 2 1",
			"2006 2006 3 1 0 2 2 0",
			"2007 2007 2 0 8 2 2 0",
			"2008 9999 3 1 0 2 2 0",
			"2008 9999 9 1 0 2 2 1"
		],
		"C-Eur": [
			"1916 1916 3 30 7 23 0 1 S",
			"1916 1916 9 1 7 1 0 0",
			"1917 1918 3 15 1 2 2 1 S",
			"1917 1918 8 15 1 2 2 0",
			"1940 1940 3 1 7 2 2 1 S",
			"1942 1942 10 2 7 2 2 0",
			"1943 1943 2 29 7 2 2 1 S",
			"1943 1943 9 4 7 2 2 0",
			"1944 1945 3 1 1 2 2 1 S",
			"1944 1944 9 2 7 2 2 0",
			"1945 1945 8 16 7 2 2 0",
			"1977 1980 3 1 0 2 2 1 S",
			"1977 1977 8 0 8 2 2 0",
			"1978 1978 9 1 7 2 2 0",
			"1979 1995 8 0 8 2 2 0",
			"1981 9999 2 0 8 2 2 1 S",
			"1996 9999 9 0 8 2 2 0"
		],
		"SovietZone": [
			"1945 1945 4 24 7 2 0 2 M",
			"1945 1945 8 24 7 3 0 1 S",
			"1945 1945 10 18 7 2 2 0"
		],
		"Germany": [
			"1946 1946 3 14 7 2 2 1 S",
			"1946 1946 9 7 7 2 2 0",
			"1947 1949 9 1 0 2 2 0",
			"1947 1947 3 6 7 3 2 1 S",
			"1947 1947 4 11 7 2 2 2 M",
			"1947 1947 5 29 7 3 0 1 S",
			"1948 1948 3 18 7 2 2 1 S",
			"1949 1949 3 10 7 2 2 1 S"
		],
		"EU": [
			"1977 1980 3 1 0 1 1 1 S",
			"1977 1977 8 0 8 1 1 0",
			"1978 1978 9 1 7 1 1 0",
			"1979 1995 8 0 8 1 1 0",
			"1981 9999 2 0 8 1 1 1 S",
			"1996 9999 9 0 8 1 1 0"
		],
		"GB-Eire": [
			"1916 1916 4 21 7 2 2 1 BST",
			"1916 1916 9 1 7 2 2 0 GMT",
			"1917 1917 3 8 7 2 2 1 BST",
			"1917 1917 8 17 7 2 2 0 GMT",
			"1918 1918 2 24 7 2 2 1 BST",
			"1918 1918 8 30 7 2 2 0 GMT",
			"1919 1919 2 30 7 2 2 1 BST",
			"1919 1919 8 29 7 2 2 0 GMT",
			"1920 1920 2 28 7 2 2 1 BST",
			"1920 1920 9 25 7 2 2 0 GMT",
			"1921 1921 3 3 7 2 2 1 BST",
			"1921 1921 9 3 7 2 2 0 GMT",
			"1922 1922 2 26 7 2 2 1 BST",
			"1922 1922 9 8 7 2 2 0 GMT",
			"1923 1923 3 16 0 2 2 1 BST",
			"1923 1924 8 16 0 2 2 0 GMT",
			"1924 1924 3 9 0 2 2 1 BST",
			"1925 1926 3 16 0 2 2 1 BST",
			"1925 1938 9 2 0 2 2 0 GMT",
			"1927 1927 3 9 0 2 2 1 BST",
			"1928 1929 3 16 0 2 2 1 BST",
			"1930 1930 3 9 0 2 2 1 BST",
			"1931 1932 3 16 0 2 2 1 BST",
			"1933 1933 3 9 0 2 2 1 BST",
			"1934 1934 3 16 0 2 2 1 BST",
			"1935 1935 3 9 0 2 2 1 BST",
			"1936 1937 3 16 0 2 2 1 BST",
			"1938 1938 3 9 0 2 2 1 BST",
			"1939 1939 3 16 0 2 2 1 BST",
			"1939 1939 10 16 0 2 2 0 GMT",
			"1940 1940 1 23 0 2 2 1 BST",
			"1941 1941 4 2 0 1 2 2 BDST",
			"1941 1943 7 9 0 1 2 1 BST",
			"1942 1944 3 2 0 1 2 2 BDST",
			"1944 1944 8 16 0 1 2 1 BST",
			"1945 1945 3 2 1 1 2 2 BDST",
			"1945 1945 6 9 0 1 2 1 BST",
			"1945 1946 9 2 0 2 2 0 GMT",
			"1946 1946 3 9 0 2 2 1 BST",
			"1947 1947 2 16 7 2 2 1 BST",
			"1947 1947 3 13 7 1 2 2 BDST",
			"1947 1947 7 10 7 1 2 1 BST",
			"1947 1947 10 2 7 2 2 0 GMT",
			"1948 1948 2 14 7 2 2 1 BST",
			"1948 1948 9 31 7 2 2 0 GMT",
			"1949 1949 3 3 7 2 2 1 BST",
			"1949 1949 9 30 7 2 2 0 GMT",
			"1950 1952 3 14 0 2 2 1 BST",
			"1950 1952 9 21 0 2 2 0 GMT",
			"1953 1953 3 16 0 2 2 1 BST",
			"1953 1960 9 2 0 2 2 0 GMT",
			"1954 1954 3 9 0 2 2 1 BST",
			"1955 1956 3 16 0 2 2 1 BST",
			"1957 1957 3 9 0 2 2 1 BST",
			"1958 1959 3 16 0 2 2 1 BST",
			"1960 1960 3 9 0 2 2 1 BST",
			"1961 1963 2 0 8 2 2 1 BST",
			"1961 1968 9 23 0 2 2 0 GMT",
			"1964 1967 2 19 0 2 2 1 BST",
			"1968 1968 1 18 7 2 2 1 BST",
			"1972 1980 2 16 0 2 2 1 BST",
			"1972 1980 9 23 0 2 2 0 GMT",
			"1981 1995 2 0 8 1 1 1 BST",
			"1981 1989 9 23 0 1 1 0 GMT",
			"1990 1995 9 22 0 1 1 0 GMT"
		],
		"Russia": [
			"1917 1917 6 1 7 23 0 1 MST",
			"1917 1917 11 28 7 0 0 0 MMT",
			"1918 1918 4 31 7 22 0 2 MDST",
			"1918 1918 8 16 7 1 0 1 MST",
			"1919 1919 4 31 7 23 0 2 MDST",
			"1919 1919 6 1 7 2 0 1 S",
			"1919 1919 7 16 7 0 0 0",
			"1921 1921 1 14 7 23 0 1 S",
			"1921 1921 2 20 7 23 0 2 M",
			"1921 1921 8 1 7 0 0 1 S",
			"1921 1921 9 1 7 0 0 0",
			"1981 1984 3 1 7 0 0 1 S",
			"1981 1983 9 1 7 0 0 0",
			"1984 1991 8 0 8 2 2 0",
			"1985 1991 2 0 8 2 2 1 S",
			"1992 1992 2 6 8 23 0 1 S",
			"1992 1992 8 6 8 23 0 0",
			"1993 2010 2 0 8 2 2 1 S",
			"1993 1995 8 0 8 2 2 0",
			"1996 2010 9 0 8 2 2 0"
		],
		"NZ": [
			"1927 1927 10 6 7 2 0 1 S",
			"1928 1928 2 4 7 2 0 0 M",
			"1928 1933 9 8 0 2 0 0:30 S",
			"1929 1933 2 15 0 2 0 0 M",
			"1934 1940 3 0 8 2 0 0 M",
			"1934 1940 8 0 8 2 0 0:30 S",
			"1946 1946 0 1 7 0 0 0 S",
			"1974 1974 10 1 0 2 2 1 D",
			"1975 1975 1 0 8 2 2 0 S",
			"1975 1988 9 0 8 2 2 1 D",
			"1976 1989 2 1 0 2 2 0 S",
			"1989 1989 9 8 0 2 2 1 D",
			"1990 2006 9 1 0 2 2 1 D",
			"1990 2007 2 15 0 2 2 0 S",
			"2007 9999 8 0 8 2 2 1 D",
			"2008 9999 3 1 0 2 2 0 S"
		]
	},
	"links": {}
});
