#!/bin/bash

# Version : 0.06

# Author : darrenldl (dldldev@yahoo.com)

#    ezsetfacl.sh is mainly used to simplify the task of using setfacl across multiple files
#    Copyright 2014 darrenldl

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.



# Initialisation

filelist=""
users=()
groups=()

line_no=1
a_line_no=1
file_no=0
dir_no=0
acl_block_no=0
fl_start=0	# fl_start is used by second part of code	
fl_end=0	# fl_end is used by second part of code
c_error=0	# c_error = config error
c_warn=0	# c_warn = config warning counter ( non-critical mistakes )
fl_o=0		# flag operation, is used to indicated finished operation
fl_all=0	# fl_all is used to check if ALL is used
fl_others=0	# fl_others is used to check if other words are used with ALL(if ALL is used, ALL should be the only operand)
fl_u_valid_line=()	# fl_u_valid stores flags to indicate whether users in config are present in users array, in the current line
fl_u_checked=()		# fl_u_checked stores if the user is already mentioned
fl_g_valid_line=()	# fl_g_valid stores flags to indicate whether groups in config are present in groups array, in the current line
fl_g_checked=()		# fl_g_checked stores if the group is already mentioned
fl_u_check=0
fl_g_check=0
fl_u=()			# fl_u is used by second part of code
fl_g=()			# fl_g ss used by second part of code
fl_r_u=0
fl_r_g=0
fl_e_u=0
fl_e_g=0
fl_no=0		# fl_no is used in second part of code
fl_no_b=0
fl_f_list=0
fl_e=0
fl_i=1
fl_l=0
fl_f_list=0
fl_f_list_type=0
fl_perm_check=0
fl_perm=0
fl_dperm=0
fl_recur=0
fl_P=0
fl_D=0
fl_R=0
fl_P_s=0
fl_D_s=0
fl_R_s=0
fl_apply=0
fl_gen=0
fl_I_a=0
fl_I_d=0
fl_I_g=0
fl_I_h=0
fl_I_t=0
fl_I_s=0
fl_f_specified=0
fl_NOALL=0
temp=()
temp2=0
fl_debug=0
fl_stray_c=0
fl_stray_P_str=0
fl_stray_D_str=0
s_aperm=0
fl_one_line_file=0
fl_chown_c=0
fl_chown_u=""
fl_chown_g=""
fl_chown_u_c=0
fl_chown_g_c=0
fl_chown_u_specified=0
fl_chown_g_specified=0
chmod_perm_string=""
stray_no=0
chown_no=0
chown_file_no=0
chown_dir_no=0
chmod_no=0
chmod_file_no=0
chmod_dir_no=0
fl_chattr_recur=0
fl_chattr_verbose=0
fl_chattr_version=0
fl_chattr_version_c=0
chattr_version_no=0
chattr_no=0
chattr_file_no=0
chattr_string=""
chattr_arg_string=""
fl_start_type=0
fl_w_list=0
fl_w_list_type=0
fl_append_specified=0
fl_insert_specified=0
fl_replace_specified=0
append_no=0
append_text_no=0
append_file_no=0
insert_no=0
insert_text_no=0
insert_file_no=0
replace_no=0
replace_old_text_no=0
replace_new_text_no=0
replace_file_no=0

append_string_buffer=""
append_string_buffer_count=0
fl_append_string_first=1

insert_string_buffer=""
insert_string_buffer_count=0
insert_string_buffer_after=""
insert_string_buffer_after_count=0
fl_insert_string_first=1
fl_insert_string_after_first=1
insert_string_buffer_array=()
insert_string_buffer_after_array=()
fl_insert_line=0
fl_insert_after=0
fl_insert_index=0
fl_insert_index_after=0
fl_insert_sed_mul_line_index=0
insert_sed_mul_line_string_array=()
fl_insert_block_completed=1
insert_line_or_after=()
insert_line_number=0
insert_line_number_array=()
insert_filename_string=""

fl_replace_with=0
fl_replace_index=0
replace_string_buffer=""
fl_replace_string_first=1
replace_string_buffer_with=""
fl_replace_string_with_first=1
sed_mul_line_string=""
replace_string_buffer_array=()
replace_string_buffer_with_array=()
fl_replace_block_completed=1
replace_mul_line=0
replace_filename_string=""

fl_command_specified=0
cmd_no=0
cmd_line_no=0

fl_nm_list_ug=0
fl_nm_list_ft=0
fl_nm_list_specified=0

nm_list_file_no=0
nm_list_file_line_no=0
nm_list_file_a_line_no=0
nm_list_user_no=0
nm_list_group_no=0
nm_list_no=0

nm_list_line_raw=""
nm_list_word=""
nm_list_line=()

nm_list_file=""
fl_restrict_specified=0

file_name_stitch_c=0
file_name_stitch_string=""

temp3=""
temp4=""
temp5=0
temp6=""

end_line_no=0
end_temp_line_no=0
end_line_array=()
end_line_no_temp=0
end_line_no_string=""
end_line_raw=""
end_word=""
end_line=()

char_escape_warn_cw=0
fl_I_cw_c=0
char_escape_warn_w=1
fl_I_w_c=0

filename_auto_stitch=0
fl_I_fnas_c=0
stray_file_index=0
stray_file_array=()

after_line_no=0
with_line_no=0

fl_chown_recur=0
fl_chmod_recur=0

gen_script_w=1
fl_I_gs_w_c=0

echo_msg_red='\033[0;31m'
echo_msg_yellow='\033[1;33m'
echo_colour=1

# Interface
for (( i=1; i <= $#; i++ )); do
	temp=${!i}
	if [[ "$temp" == --* ]]; then
		case $temp in
			--apply )
					if (( $fl_I_a == 1 )); then
						echo " -a repeated"
						exit
					fi
					fl_I_a=1
				;;
			--timestamp )
					if (( $fl_I_d == 1 )); then
						echo " -d repeated"
						exit
					fi
					fl_I_d=1
				;;
			--generate )
					if (( $fl_I_g == 1 )); then
						echo " -g repeated"
						exit
					fi
					fl_I_g=1
				;;
			--help )
					echo "Usage : ./ezsetfacl.sh [OPTIONS] [file list]"
					echo ""
					echo "Options :"
					echo "    -a, --apply                       apply rules"
					echo "    -d, --timestamp                   prepend a line for data and time"
					echo "    -g, --generate                    generate commands"
					echo "    -h, --help                        show help message"
					echo "    -t, --test                        check errors only"
					echo "    -s, --stat                        show statistics"
					echo ""
					echo "    --cw, --commentedwarning          show commented warning text messages in generate mode,"
					echo "                                      regardless of whether apply mode is chosen"
					echo "    --ncw, --nocommentedwarning       do not show commented warning (default) "
					echo "    --w, --warning                    show warning text messages(default),"
					echo "                                      only when only apply mode is chosen"
					echo "    --nw, --nowarning                 do not show warning text messages,"
					echo "                                      only when only apply mode is chosen"
					echo "    --filename_auto_stitch            adds '\' automatically to file names with spaces if not already"
					echo "                                      Warning: auto_stitch will render individual permissions"
					echo "                                           specified in @RESTRICT useless, as the permissions"
					echo "                                           are stitched into file name as well"
					echo "    --gs_w, --gen_script_warning      enable warning function in generated script(default)"
					echo "                                      for dynamic functions(e.g. file detections)"
					echo "    --gs_nw, --gen_script_nowarning   disable warning function in generated script"
					echo "                                      for dynamic functions(e.g. file detections)"
					echo ""
					echo "    --example                         show exampls"
					echo "    --debug                           show processed lines, may not be fully functional"
					echo "    --tea                             tea"
					exit
				;;
			--example )
					echo ""
					echo "----####################################----"
					echo "@NAME_LIST Target Type"
					echo ">START"
					echo "[...]"
					echo "<END"
					echo "Target: USR/GRP"
					echo "Type: FILE/TEXT"
					echo ""
					echo "@NAME_LIST USR TEXT"
					echo ">START"
					echo "darren alice"
					echo "bob"
					echo "<END"
					echo ""
					echo "@NAME_LIST USR FILE"
					echo ">START"
					echo "namelist1"
					echo "namelist2"
					echo "<END"
					echo "----####################################----"
					echo "@STRAY [NO] RES Target Name Perm_type Permission [Perm_type Permission] [R] file"
					echo "Target: USR/GRP"
					echo "Perm_type: P, D"
					echo ""
					echo "@STRAY RES USR darren P --- D --- /usr/bin/su"
					echo "@STRAY RES GRP users P --- /usr/bin/su"
					echo "----####################################----"
					echo "@CHOWN Target Name [Target Name] [RECUR]"
					echo "file"
					echo "[...]"
					echo "<END"
					echo "Target: USER, GROUP"
					echo ""
					echo "@CHOWN USER darren GROUP users"
					echo "/home/darrenldl"
					echo "<END"
					echo "----####################################----"
					echo "@CHMOD TargetOperandPermission[,TargetOperandPermission] [RECUR]"
					echo "file"
					echo "[...]"
					echo "<END"
					echo "Target: u, g, o, a"
					echo "Operand: = + -"
					echo "Permission: blank or combination of r w x"
					echo ""
					echo "@CHMOD u=rwx,g=rx,o="
					echo "/usr/bin/su"
					echo "<END"
					echo "----####################################----"
					echo "@CHATTR [RECUR] [VERBOSE] [VERSION number] Attributes"
					echo "file"
					echo "[...]"
					echo "<END"
					echo "Attributes: Refer to man chattr"
					echo ""
					echo "@CHATTR +i"
					echo "/usr/bin/su"
					echo "<END"
					echo "----####################################----"
					echo "@APPEND"
					echo "text"
					echo "[...]"
					echo ">START"
					echo "file"
					echo "[...]"
					echo "<END"
					echo ""
					echo "@APPEND"
					echo "Hello"
					echo "Goodbye"
					echo ">START"
					echo "text_file"
					echo "<END"
					echo "----####################################----"
					echo "@INSERT"
					echo "text"
					echo "[...]"
					echo "@AFTER"
					echo "text"
					echo "[...]"
					echo ">START"
					echo "file"
					echo "[...]"
					echo "<END"
					echo ""
					echo "@INSERT"
					echo "Goodbye"
					echo "@AFTER"
					echo "Hello"
					echo ">START"
					echo "text_file"
					echo "<END"
					echo ""
					echo "@INSERT"
					echo "text"
					echo "[...]"
					echo "@LINE number"
					echo ">START"
					echo "file"
					echo "[...]"
					echo "<END"
					echo ""
					echo "@INSERT"
					echo "Hello"
					echo "@LINE 10"
					echo ">START"
					echo "text_file"
					echo "<END"
					echo "----####################################----"
					echo "@REPLACE"
					echo "text"
					echo "[...]"
					echo "@WITH"
					echo "text"
					echo "[...]"
					echo ">START"
					echo "file"
					echo "[...]"
					echo "<END"
					echo ""
					echo "@REPLACE"
					echo "Hello"
					echo "@WITH"
					echo "Goodbye"
					echo ">START"
					echo "text_file"
					echo "<END"
					echo "----####################################----"
					echo "@COMMAND"
					echo ">START"
					echo "command"
					echo "[...]"
					echo "<END"
					echo "----####################################----"
					echo "[!NO]"
					echo "@RESTRICT Target name"
					echo "[@RESTRICT Target name]"
					echo "[@EXCLUDE Target name]"
					echo "[@EXCLUDE Target name]"
					echo "Perm_type Permission"
					echo "[Perm_type Permission]"
					echo "[+RECUR]"
					echo ">START"
					echo "file"
					echo "[...]"
					echo "<END"
					echo "Target: USER, GROUP"
					echo "Perm_type: +PERM, +DPERM"
					echo "Permission: Combination of r w x -, length: 3 characters"
					echo ""
					echo "@RESTRICT USER darren alice bob"
					echo "@RESTRICT GROUP users http video"
					echo "@EXCLUDE USER bob"
					echo "@EXCLUDE GROUP http video"
					echo "+PERM ---"
					echo ">START"
					echo "/usr/bin/su"
					echo "<END"
					echo "----####################################----"
					exit
				;;
			--test )	
					if (( $fl_I_t == 1 )); then
						echo " -t repeated"
						exit
					fi
					fl_I_t=1
				;;
			--stat )
					if (( $fl_I_s == 1 )); then
						echo " -s repeated"
						exit
					fi
					fl_I_s=1
				;;
			--commentedwarning | --cw )
					if (( $fl_I_cw_c == 1 )); then
						echo " --cw or --ncw has been specified"
						exit
					fi
					fl_I_cw_c=1
					char_escape_warn_cw=1
				;;
			--nocommentedwarning | --ncw )
					if (( $fl_I_cw_c == 1 )); then
						echo " --cw or --ncw has been specified"
						exit
					fi
					fl_I_cw_c=1
					char_escape_warn_cw=0
				;;
			--warning | --w )
					if (( $fl_I_w_c == 1 )); then
						echo " --w or --nw has been specified"
						exit
					fi
					fl_I_w_c=1
					char_escape_warn_w=1
				;;
			--nowarning | --nw )
					if (( $fl_I_w_c == 1 )); then
						echo " --w or --nw has been specified"
						exit
					fi
					fl_I_w_c=1
					char_escape_warn_w=0
				;;
			--filename_auto_stitch )
					if (( $fl_I_fnas_c == 1 )); then
						echo " --filename_auto_stitch repeated"
						exit
					fi
					fl_I_fnas_c=1
					filename_auto_stitch=1
				;;
			--gs_w | --gen_script_warning )
					if (( $fl_I_gs_w_c == 1 )); then
						echo " --gs_w or --gs_nw has been specified"
						exit
					fi
					fl_I_gs_w_c=1
					gen_script_w=1
				;;
			--gs_nw | --gen_script_nowarning )
					if (( $fl_I_gs_w_c == 1 )); then
						echo " --gs_w or --gs_nw has been specified"
						exit
					fi
					fl_I_gs_w_c=1
					gen_script_w=0
				;;
			--debug )
					if (( $fl_debug == 1 )); then
						echo " --debug repeated"
						exit
					fi
					fl_debug=1
				;;
			--tea )
					echo "###################################"
					echo "#                                 #"
					echo "#             *  *  *             #"
					echo "#            *  *  *              #"
					echo "#            *  *  *              #"
					echo "#             *  *  *             #"
					echo "#              *  *  *            #"
					echo "#              *  *  *            #"
					echo "#         ##  *  *  *  ##         #"
					echo "#      #####...........##         #"
					echo "#     ##  ##           ##         #"
					echo "#     ##  ##           ##         #"
					echo "#     ##  ##           ##         #"
					echo "#      #####           ##         #"
					echo "#          ##         ##          #"
					echo "#           ###########           #"
					echo "#                                 #"
					echo "#               Tea.              #"
					echo "#                                 #"
					echo "###################################"
					exit
				;;
			* )		echo "Invalid options"
					exit
				;;
		esac
		if (( $fl_I_t == 1 )) && [[ (( $fl_I_a == 1 )) || (( $fl_I_g == 1 )) ]]; then
			echo "-t cannot be used with -a or -g"
			exit
		fi
	else	if [[ "$temp" == -* ]]; then
			for (( j=1; j < ${#temp}; j++)); do
				case ${temp:$j:1} in
					a )	if (( $fl_I_a == 1 )); then
								echo " -a repeated"
								exit
							fi
							fl_I_a=1
						;;
					d )	if (( $fl_I_d == 1 )); then
							echo " -d repeated"
							exit
						fi
						fl_I_d=1
						;;
					g )	if (( $fl_I_g == 1 )); then
							echo " -g repeated"
							exit
						fi
						fl_I_g=1
						;;
					h )
							echo "Usage : ./ezsetfacl.sh [OPTIONS] [file list]"
							echo ""
							echo "Options :"
							echo "    -a, --apply                       apply rules"
							echo "    -d, --timestamp                   prepend a line for data and time"
							echo "    -g, --generate                    generate commands"
							echo "    -h, --help                        show help message"
							echo "    -t, --test                        check errors only"
							echo "    -s, --stat                        show statistics"
							echo ""
							echo "    --cw, --commentedwarning          show commented warning text messages in generate mode,"
							echo "                                      regardless of whether apply mode is chosen"
							echo "    --ncw, --nocommentedwarning       do not show commented warning (default) "
							echo "    --w, --warning                    show warning text messages(default),"
							echo "                                      only when only apply mode is chosen"
							echo "    --nw, --nowarning                 do not show warning text messages,"
							echo "                                      only when only apply mode is chosen"
							echo "    --filename_auto_stitch            adds '\' automatically to file names with spaces if not already"
							echo "                                      Warning: auto_stitch will render individual permissions"
							echo "                                           specified in @RESTRICT useless, as the permissions"
							echo "                                           are stitched into file name as well"
							echo "    --gs_w, --gen_script_warning      enable warning function in generated script(default)"
							echo "                                      for dynamic functions(e.g. file detections)"
							echo "    --gs_nw, --gen_script_nowarning   disable warning function in generated script"
							echo "                                      for dynamic functions(e.g. file detections)"
							echo ""
							echo "    --example                         show exampls"
							echo "    --debug                           show processed lines, may not be fully functional"
							echo "    --tea                             tea"
							exit
						;;
					t )	if (( $fl_I_t == 1 )); then
							echo " -t repeated"
							exit
						fi
						fl_I_t=1
						;;
					s )	if (( $fl_I_s == 1 )); then
							echo " -s repeated"
							exit
						fi
						fl_I_s=1
						;;
					* )	echo "Invalid options"
						exit
						;;
				esac
				if (( $fl_I_t == 1 )) && [[ (( $fl_I_a == 1 )) || (( $fl_I_g == 1 )) ]]; then
					echo "-t cannot be used with -a or -g"
					exit
				fi
			done
		else
			if (( $fl_f_specified == 0 )); then
				filelist=${!i}
				fl_f_specified=1
			else
				echo "Please specify only one file list"
				exit
			fi
		fi
	fi
done

if (( $fl_f_specified == 0 )); then
	echo "Please specify file list"
	exit
fi

if (( $[ $fl_I_a + $fl_I_g + $fl_I_t + $fl_I_s] == 0 )); then
	echo "Please specify at least one action"
	exit
fi

if (( $fl_I_s == 1 )) && (( $[ $fl_I_a + $fl_I_g + $fl_I_t ] == 0 )); then
	echo "Statistics option cannot be used alone, please specify -a, -g or -t"
	exit
fi

fl_apply=$fl_I_a
fl_gen=$fl_I_g

if [ ! -f "$filelist" ]; then
    echo "File list does not exist"
    exit
fi

function char_escape {		# char_escape line_raw
	local f__str=${!1}
	local f__str2="$1"
	if [[ $f__str =~ \* ]]; then
		f__str=$( echo "$f__str" | sed 's/\*/\\\*/g' )
		if (( $char_escape_warn_cw == 1 )); then
			echo "# Warning : $line_no : char_escape : wildcard detected, escaped character"
		fi
		if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
			echo "Warning : $line_no : char_escape : wildcard detected, escaped character"
		fi
		((c_warn++))
	fi
	local i="$[${#f__str}-1]"
	local c=0
	if [[ ${f__str:$i:1} == '\' ]]; then
		for ((a = 0; a < $i; a++)); do
			if [[ ${f__str:$i-a:1} == '\' ]]; then
				((c++))
			else
				break
			fi
		done
		if (( $c % 2 == 1 )); then
			f__str=$f__str'\'
			if (( $char_escape_warn_cw == 1 )); then
				echo "# Warning : $line_no : char_escape : trailing '\' detected, escaped character"
			fi
			if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
				echo "Warning : $line_no : char_escape : trailing '\' detected, escaped character"
			fi
			((c_warn++))
		fi
	fi
	if [[ $f__str =~ '\a' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\a/\\\\a/g' )
		if (( $char_escape_warn_cw == 1 )); then
			echo "# Warning : $line_no : char_escape : '\a' detected, escaped character"
		fi
		if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
			echo "Warning : $line_no : char_escape : '\a' detected, escaped character"
		fi
		((c_warn++))
	fi
	if [[ $f__str =~ '\b' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\b/\\\\b/g' )
		if (( $char_escape_warn_cw == 1 )); then
			echo "# Warning : $line_no : char_escape : '\b' detected, escaped character"
		fi
		if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
			echo "Warning : $line_no : char_escape : '\b' detected, escaped character"
		fi
		((c_warn++))
	fi
	if [[ $f__str =~ '\c' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\c/\\\\c/g' )
		if (( $char_escape_warn_cw == 1 )); then
			echo "# Warning : $line_no : char_escape : '\c' detected, escaped character"
		fi
		if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
			echo "Warning : $line_no : char_escape : '\c' detected, escaped character"
		fi
		((c_warn++))
	fi
	if [[ $f__str =~ '\e' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\e/\\\\e/g' )
		if (( $char_escape_warn_cw == 1 )); then
			echo "# Warning : $line_no : char_escape : '\e' detected, escaped character"
		fi
		if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
			echo "Warning : $line_no : char_escape : '\e' detected, escaped character"
		fi
		((c_warn++))
	fi
	if [[ $f__str =~ '\f' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\f/\\\\f/g' )
		if (( $char_escape_warn_cw == 1 )); then
			echo "# Warning : $line_no : char_escape : '\f' detected, escaped character"
		fi
		if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
			echo "Warning : $line_no : char_escape : '\f' detected, escaped character"
		fi
		((c_warn++))
	fi
	if [[ $f__str =~ '\n' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\n/\\\\n/g' )
		if (( $char_escape_warn_cw == 1 )); then
			echo "# Warning : $line_no : char_escape : '\n' detected, escaped character"
		fi
		if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
			echo "Warning : $line_no : char_escape : '\n' detected, escaped character"
		fi
		((c_warn++))
	fi
	if [[ $f__str =~ '\r' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\r/\\\\r/g' )
		if (( $char_escape_warn_cw == 1 )); then
			echo "# Warning : $line_no : char_escape : '\r' detected, escaped character"
		fi
		if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
			echo "Warning : $line_no : char_escape : '\r' detected, escaped character"
		fi
		((c_warn++))
	fi
	if [[ $f__str =~ '\t' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\t/\\\\t/g' )
		if (( $char_escape_warn_cw == 1 )); then
			echo "# Warning : $line_no : char_escape : '\t' detected, escaped character"
		fi
		if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
			echo "Warning : $line_no : char_escape : '\t' detected, escaped character"
		fi
		((c_warn++))
	fi
	if [[ $f__str =~ '\v' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\v/\\\\v/g' )
		if (( $char_escape_warn_cw == 1 )); then
			echo "# Warning : $line_no : char_escape : '\v' detected, escaped character"
		fi
		if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
			echo "Warning : $line_no : char_escape : '\v' detected, escaped character"
		fi
		((c_warn++))
	fi
	#if [[ $f__str =~ '(' ]]; then
	#	f__str=$( echo "$f__str" | sed 's/(/\\(/g' )
	#	if (( $char_escape_warn_cw == 1 )); then
	#		echo "# Warning : $line_no : char_escape : '(' detected, escaped character"
	#	fi
	#	if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
	#		echo "Warning : $line_no : char_escape : '(' detected, escaped character"
	#	fi
	#	((c_warn++))
	#fi
	#if [[ $f__str =~ ')' ]]; then
	#	f__str=$( echo "$f__str" | sed 's/)/\\)/g' )
	#	if (( $char_escape_warn_cw == 1 )); then
	#		echo "# Warning : $line_no : char_escape : ')' detected, escaped character"
	#	fi
	#	if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
	#		echo "Warning : $line_no : char_escape : ')' detected, escaped character"
	#	fi
	#	((c_warn++))
	#fi
	if [[ $f__str =~ '"' ]]; then
		f__str=$( echo "$f__str" | sed 's/\"/\\\"/g' )
		if (( $char_escape_warn_cw == 1 )); then
			echo "# Warning : $line_no : char_escape : '\"' detected, escaped character"
		fi
		if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
			echo "Warning : $line_no : char_escape : '\"' detected, escaped character"
		fi
		((c_warn++))
	fi
	if [[ $f__str =~ "'" ]]; then
		#f__str=$( echo "$f__str" | sed "s/'/\\\\'''\\\''''/g" )
      #f__str=$( echo "$f__str" | sed "s/'/\\\'/g" )
		if (( $char_escape_warn_cw == 1 )); then
			echo "# Warning : $line_no : char_escape : single quote detected, escaped character"
		fi
		if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
			echo "Warning : $line_no : char_escape : single quote detected, escaped character"
		fi
		((c_warn++))
	fi
	#eval $f__str2="'$f__str'"
   export "$f__str2"="$f__str"
}

function char_escape_quiet {		# char_escape_quiet line_raw
	local f__str=${!1}
	local f__str2="$1"
	if [[ $f__str =~ \* ]]; then
		f__str=$( echo "$f__str" | sed 's/\*/\\\*/g' )
		((c_warn++))
	fi
	local i="$[${#f__str}-1]"
	local c=0
	if [[ ${f__str:$i:1} == '\' ]]; then
		for ((a = 0; a < $i; a++)); do
			if [[ ${f__str:$i-a:1} == '\' ]]; then
				((c++))
			else
				break
			fi
		done
		if (( $c % 2 == 1 )); then
			f__str=$f__str'\'
		fi
	fi
	if [[ $f__str =~ '\a' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\a/\\\\a/g' )
		((c_warn++))
	fi
	if [[ $f__str =~ '\b' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\b/\\\\b/g' )
	fi
	if [[ $f__str =~ '\c' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\c/\\\\c/g' )
	fi
	if [[ $f__str =~ '\e' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\e/\\\\e/g' )
	fi
	if [[ $f__str =~ '\f' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\f/\\\\f/g' )
	fi
	if [[ $f__str =~ '\n' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\n/\\\\n/g' )
	fi
	if [[ $f__str =~ '\r' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\r/\\\\r/g' )
	fi
	if [[ $f__str =~ '\t' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\t/\\\\t/g' )
	fi
	if [[ $f__str =~ '\v' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\v/\\\\v/g' )
	fi
	#if [[ $f__str =~ '(' ]]; then
	#	f__str=$( echo "$f__str" | sed 's/(/\\(/g' )
	#fi
	#if [[ $f__str =~ ')' ]]; then
	#	f__str=$( echo "$f__str" | sed 's/)/\\)/g' )
	#fi
	if [[ $f__str =~ '"' ]]; then
		f__str=$( echo "$f__str" | sed 's/"/\\\"/g' )
	fi
	#if [[ $f__str =~ "'" ]]; then
	#	#f__str=$( echo "$f__str" | sed "s/'/\\\\'''\\\''''/g" )
   #   f__str=$( echo "$f__str" | sed "s/'/\\\'/g" )
	#fi
	#eval $f__str2="'$f__str'"
   export "$f__str2"="$f__str"
}

function char_deescape {
	local f__str=${!1}
	local f__str2="$1"
	if [[ $f__str =~ \\\* ]]; then					# If line_raw contains wildcard,
		f__str=$( echo "$f__str" | sed 's/\\\*/*/g' )	# swap '*' to '\*' to avoid unexpected behavior
	fi
	if [[ $f__str =~ '\\a' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\a/\\a/g' )
	fi
	if [[ $f__str =~ '\\b' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\b/\\b/g' )
	fi
	if [[ $f__str =~ '\\c' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\c/\\c/g' )
	fi
	if [[ $f__str =~ '\\e' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\e/\\e/g' )
	fi
	if [[ $f__str =~ '\\f' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\f/\\f/g' )
	fi
	if [[ $f__str =~ '\\n' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\n/\\n/g' )
	fi
	if [[ $f__str =~ '\\r' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\r/\\r/g' )
	fi
	if [[ $f__str =~ '\\t' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\t/\\t/g' )
	fi
	if [[ $f__str =~ '\\v' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\v/\\v/g' )
	fi
	if [[ $f__str =~ '\"' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\"/"/g' )
	fi
	#if [[ $f__str =~ "'" ]]; then
	#	f_str=$( echo "$f__str" | sed "s/\\\'/'/g" )
	#fi
	#if [[ $f__str =~ '\(' ]]; then
	#	f__str=$( echo "$f__str" | sed 's/\(/(/g' )
	#fi
	#if [[ $f__str =~ '\)' ]]; then
	#	f__str=$( echo "$f__str" | sed 's/\)/)/g' )
	#fi
	#eval $f__str2="'$f__str'"
   export "$f__str2"="$f__str"
}

function char_deescape_echo {		# char_deescape_echo line
	local f__str=${!1}
	if [[ $f__str =~ \\\* ]]; then					# If line_raw contains wildcard,
		f__str=$( echo "$f__str" | sed 's/\\\*/*/g' )	# swap '*' to '\*' to avoid unexpected behavior
	fi
	if [[ $f__str =~ '\\a' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\a/\\a/g' )
	fi
	if [[ $f__str =~ '\\b' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\b/\\b/g' )
	fi
	if [[ $f__str =~ '\\c' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\c/\\c/g' )
	fi
	if [[ $f__str =~ '\\e' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\e/\\e/g' )
	fi
	if [[ $f__str =~ '\\f' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\f/\\f/g' )
	fi
	if [[ $f__str =~ '\\n' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\n/\\n/g' )
	fi
	if [[ $f__str =~ '\\r' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\r/\\r/g' )
	fi
	if [[ $f__str =~ '\\t' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\t/\\t/g' )
	fi
	if [[ $f__str =~ '\\v' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\\v/\\v/g' )
	fi
	if [[ $f__str =~ '\"' ]]; then
		f__str=$( echo "$f__str" | sed 's/\\\"/"/g' )
	fi
	#if [[ $f__str =~ "'" ]]; then
	#	f_str=$( echo "$f__str" | sed "s/\\\'/'/g" )
	#fi
	#if [[ $f__str =~ '\(' ]]; then
	#	f__str=$( echo "$f__str" | sed 's/\(/(/g' )
	#fi
	#if [[ $f__str =~ '\)' ]]; then
	#	f__str=$( echo "$f__str" | sed 's/\)/)/g' )
	#fi
	echo -E "$f__str"
}

function perm_check {           # perm_check string flag
	local f__str="$1"
	local f__flag="$2"
	if [[ $f__str =~ ^[0-9]+$ ]]; then	# Check if permission number is used
		if (( $f__str > 7 || $f__str < 0 )); then
			# Invalid number
			eval $f__flag="'1'"
		fi
	else
		if (( ${#f__str} != 3 )); then	# Check length of f__string, which should be 3 characters long
			# Invalid string
			eval $f__flag="'2'"
		else
			if [[ ${f__str:0:1} == 'r' || ${f__str:0:1} == '-' ]]; then
				if [[ ${f__str:1:1} == 'w' || ${f__str:1:1} == '-' ]]; then
					if ! [[ ${f__str:2:1} == 'x' || ${f__str:2:1} == '-' ]]; then
						# Invalid f__string
						eval $f__flag="'2'"
					fi
				else
					# Invalid f__string
					eval $f__flag="'2'"
				fi
			else
				# Invalid f__string
				eval $f__flag="'2'"
			fi
		fi
	fi
}

function perm_set {             # perm_set users[@] groups[@] fl_u[@] fl_g[@] fl_no perm file fl_D fl_R fl_NOALL fl_apply fl_gen
	local f__users=("${!1}")
	local f__groups=("${!2}")
	local f__fl_u=("${!3}")
	local f__fl_g=("${!4}")
	local f__fl_no=${!5}
	local f__perm=${!6}
	local f__file=${!7}
	local f__fl_D=${!8}
	local f__fl_R=${!9}
	local f__fl_NOALL=${!10}
	local f__fl_apply=${!11}
	local f__fl_gen=${!12}
	if (( $f__fl_NOALL == 0 )); then
		for (( a=0; a < ${#f__users[@]}; a++ )); do	# Check if user is marked to be processed
			if (( ${f__fl_u[$a]} == 1 )); then
				if (( $f__fl_no == 0 )); then
					if (( $f__fl_D == 0 )); then
						if (( $f__fl_R == 0 )); then
							if (( $f__fl_apply == 1 )); then
								setfacl -m u:${f__users[$a]}:$f__perm -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -m u:${f__users[$a]}:$f__perm -- $(char_deescape_echo f__file)"
								fi
							fi
						else	if (( $f__fl_apply == 1 )); then
								setfacl -Rm u:${f__users[$a]}:$f__perm -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -Rm u:${f__users[$a]}:$f__perm -- $(char_deescape_echo f__file)"
								fi
							fi
						fi
					else
						if (( $f__fl_R == 0 )); then
							if (( $f__fl_apply == 1 )); then
								setfacl -m d:u:${f__users[$a]}:$f__perm -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -m d:u:${f__users[$a]}:$f__perm -- $(char_deescape_echo f__file)"
								fi
							fi
						else	if (( $f__fl_apply == 1 )); then
								setfacl -Rm d:u:${f__users[$a]}:$f__perm -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -Rm d:u:${f__users[$a]}:$f__perm -- $(char_deescape_echo f__file)"
								fi
							fi
						fi
					fi
				else
					if (( $f__fl_D == 0 )); then
						if (( $f__fl_R == 0 )); then
							if (( $f__fl_apply == 1 )); then
								setfacl -x u:${f__users[$a]} -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -x u:${f__users[$a]} -- $(char_deescape_echo f__file)"
								fi
							fi
						else	if (( $f__fl_apply == 1 )); then
								setfacl -Rx u:${f__users[$a]} -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -Rx u:${f__users[$a]} -- $(char_deescape_echo f__file)"
								fi
							fi
						fi
					else
						if (( $f__fl_R == 0 )); then
							if (( $f__fl_apply == 1 )); then
								setfacl -x d:u:${f__users[$a]} -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -x d:u:${f__users[$a]} -- $(char_deescape_echo f__file)"
								fi
							fi
						else	if (( $f__fl_apply == 1 )); then
								setfacl -Rx d:u:${f__users[$a]} -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -Rx d:u:${f__users[$a]} -- $(char_deescape_echo f__file)"
								fi
							fi
						fi
					fi
				fi
			fi
		done
		for (( a=0; a < ${#f__groups[@]}; a++ )); do	# Check if group is marked to be processed
			if (( ${f__fl_g[$a]} == 1 )); then
				if (( $f__fl_no == 0 )); then
					if (( $f__fl_D == 0 )); then
						if (( $f__fl_R == 0 )); then
							if (( $f__fl_apply == 1 )); then
								setfacl -m g:${f__groups[$a]}:$f__perm -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -m g:${f__groups[$a]}:$f__perm -- $(char_deescape_echo f__file)"
								fi
							fi
						else	if (( $f__fl_apply == 1 )); then
								setfacl -Rm g:${f__groups[$a]}:$f__perm -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -Rm g:${f__groups[$a]}:$f__perm -- $(char_deescape_echo f__file)"
								fi
							fi
						fi
					else
						if (( $f__fl_R == 0 )); then
							if (( $f__fl_apply == 1 )); then
								setfacl -m d:g:${f__groups[$a]}:$f__perm -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -m d:g:${f__groups[$a]}:$f__perm -- $(char_deescape_echo f__file)"
								fi
							fi
						else	if (( $f__fl_apply == 1 )); then
								setfacl -Rm d:g:${f__groups[$a]}:$f__perm -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -Rm d:g:${f__groups[$a]}:$f__perm -- $(char_deescape_echo f__file)"
								fi
							fi
						fi
					fi
				else
					if (( $f__fl_D == 0 )); then
						if (( $f__fl_R == 0 )); then
							if (( $f__fl_apply == 1 )); then
								setfacl -x g:${f__groups[$a]} -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -x g:${f__groups[$a]} -- $(char_deescape_echo f__file)"
								fi
							fi
						else	if (( $f__fl_apply == 1 )); then
								setfacl -Rx g:${f__groups[$a]} -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -Rx g:${f__groups[$a]} -- $(char_deescape_echo f__file)"
								fi
							fi
						fi
					else
						if (( $f__fl_R == 0 )); then
							if (( $f__fl_apply == 1 )); then
								setfacl -x d:g:${f__groups[$a]} -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -x d:g:${f__groups[$a]} -- $(char_deescape_echo f__file)"
								fi
							fi
						else	if (( $f__fl_apply == 1 )); then
								setfacl -Rx d:g:${f__groups[$a]} -- $(char_deescape_echo f__file)
							else	if (( $f__fl_gen == 1 )); then
									echo "setfacl -Rx d:g:${f__groups[$a]} -- $(char_deescape_echo f__file)"
								fi
							fi
						fi
					fi
				fi
			fi
		done
	else
		if (( $f__fl_apply == 1 )); then
			setfacl -b -- $(char_deescape_echo f__file)
		else	if (( $f__fl_gen == 1 )); then
				echo "setfacl -b -- $(char_deescape_echo f__file)"
			fi
		fi
	fi
}

function check_end {
	local f__line_no=0
	local f__temp_line_no=$[$line_no+1]
	local f__line_raw=""
	local f__line=()
	local f__i=0
	local f__word=""
	while read -r f__line_raw; do
		if [[ ($f__line_raw =~ ^$  || -z $f__line_raw || $f__line_raw =~ ^# ) ]]; then	# Check if line is empty/null/spaces or starts with '#'
			((f__temp_line_no++))
			continue				# If so, ignore line, check next line, still add line number though
		fi
		char_escape_quiet f__line_raw
		f__i=0
		f__line=()						# Initialise primary line buffer
		for f__word in $f__line_raw; do				# Validate each word in line
			if [[ $f__word == \#* || $f__word == '#' ]]; then	# Ignore comments
				# If word starts with '#', stop reading (probably is a comment)
				break
			fi
			f__line[$f__i]="$f__word"                              # Push words to line[]
			((f__i++))
		done
		case ${f__line[0]} in
			"@NAME_LIST")
					break
				;;
			"@STRAY"	)
					break
				;;
			"@CHOWN"	)
					break
				;;
			"@CHMOD"	)
					break
				;;
			"@CHATTR"	)
					break
				;;
			"@APPEND"	)
					break
				;;
			"@INSERT"	)
					break
				;;
			"@REPLACE"	)
					break
				;;
			"@COMMAND"	)
					break
				;;
			"!NO"	)
					break
				;;
			"@RESTRICT"	)
					break
				;;
			"@EXCLUDE"	)
					break
				;;
			"+PERM"	)
					break
				;;
			"+DPERM"	)
					break
				;;
			"+RECUR"	)
					break
				;;
			">START"	)
					break
				;;
			"<END"		)
					f__line_no=$f__temp_line_no
					((f__temp_line_no++))
				;;
			*			)
					((f__temp_line_no++))
				;;
		esac
	done < <(cat "$filelist" | sed -n "$[$line_no+1]"',$p')
	echo $f__line_no
}

function check_after {
	local f__line_no=0
	local f__temp_line_no=$[$line_no+1]
	local f__line_raw=""
	local f__line=()
	local f__i=0
	local f__word=""
	while read -r f__line_raw; do
		if [[ ($f__line_raw =~ ^$  || -z $f__line_raw || $f__line_raw =~ ^# ) ]]; then	# Check if line is empty/null/spaces or starts with '#'
			((f__temp_line_no++))
			continue				# If so, ignore line, check next line, still add line number though
		fi
		char_escape_quiet f__line_raw
		f__i=0
		f__line=()						# Initialise primary line buffer
		for f__word in $f__line_raw; do				# Validate each word in line
			if [[ $f__word == \#* || $f__word == '#' ]]; then	# Ignore comments
				# If word starts with '#', stop reading (probably is a comment)
				break
			fi
			f__line[$f__i]="$f__word"                              # Push words to line[]
			((f__i++))
		done
		case ${f__line[0]} in
			"@INSERT")
					break
				;;
			"@LINE"	)
					break
				;;
			"@AFTER"		)
					f__line_no=$f__temp_line_no
					((f__temp_line_no++))
				;;
			*			)
					((f__temp_line_no++))
				;;
		esac
	done < <(cat "$filelist" | sed -n "$[$line_no+1]"',$p')
	echo $f__line_no
}

function check_with {
	local f__line_no=0
	local f__temp_line_no=$[$line_no+1]
	local f__line_raw=""
	local f__line=()
	local f__i=0
	local f__word=""
	while read -r f__line_raw; do
		if [[ ($f__line_raw =~ ^$  || -z $f__line_raw || $f__line_raw =~ ^# ) ]]; then	# Check if line is empty/null/spaces or starts with '#'
			((f__temp_line_no++))
			continue				# If so, ignore line, check next line, still add line number though
		fi
		char_escape_quiet f__line_raw
		f__i=0
		f__line=()						# Initialise primary line buffer
		for f__word in $f__line_raw; do				# Validate each word in line
			if [[ $f__word == \#* || $f__word == '#' ]]; then	# Ignore comments
				# If word starts with '#', stop reading (probably is a comment)
				break
			fi
			f__line[$f__i]="$f__word"                              # Push words to line[]
			((f__i++))
		done
		case ${f__line[0]} in
			"@REPLACE")
					break
				;;
			"@WITH"		)
					f__line_no=$f__temp_line_no
					((f__temp_line_no++))
				;;
			*			)
					((f__temp_line_no++))
				;;
		esac
	done < <(cat "$filelist" | sed -n "$[$line_no+1]"',$p')
	echo $f__line_no
}

function filename_stitch {				# filename_stitch line[@] file_name_stitch_string file_name_stitch_c c_error
	local f__line=("${!1}")
	local f__str="$2"
	local f__count="$3"
	local f__error="$4"
	local f__stitch_c=0
	local f__stitch_string=""
	if (( ${#f__line[@]} > 1 )); then
		for (( i=0; i < ${#f__line[@]}; i++)); do
			if [[ ${f__line[$i]} == *\\ ]]; then
				f__stitch_string+=${f__line[$i]}' '
				((f__stitch_c++))
			else
				if (( $i > 0 )); then
					if [[ ${f__line[$[$i-1]]} == *\\ ]]; then
						f__stitch_string+=${f__line[$i]}
						((f__stitch_c++))
					else
						if (( $filename_auto_stitch == 1 )); then
							f__stitch_string+='\ '
							f__stitch_string+=${f__line[$i]}
							((f__stitch_c++))
							if (( $char_escape_warn_cw == 1 )); then
								echo "# Warning : $line_no : Detected missing '\' in file name, name stitched"
							fi
							if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
								echo "Warning : $line_no : Detected missing '\' in file name, name stitched"
							fi
						fi
					fi
				fi
				if (( $i == 0 )); then
					if (( $filename_auto_stitch == 1 )); then
						f__stitch_string+='\ '
						f__stitch_string+=${f__line[$i]}
						((f__stitch_c++))
						if (( $char_escape_warn_cw == 1 )); then
							echo "# Warning : $line_no : Detected missing '\' in file name, name stitched"
						fi
						if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) )) && (( $fl_gen == 0 )); then
							echo "Warning : $line_no : Detected missing '\' in file name, name stitched"
						fi
					else
						break
					fi
				fi
			fi
		done
	fi
	if (( $f__stitch_c == 0 )); then
		f__stitch_c=1
		f__stitch_string=${f__line[0]}
	fi
	eval $f__str="'$f__stitch_string'"
	eval $f__count="'$f__stitch_c'"
}

function filename_stitch_quiet {				# filename_stitch line[@] file_name_stitch_string file_name_stitch_c c_error
	local f__line=("${!1}")
	local f__str="$2"
	local f__count="$3"
	local f__error="$4"
	local f__stitch_c=0
	local f__stitch_string=""
	if (( ${#f__line[@]} > 1 )); then
		for (( i=0; i < ${#f__line[@]}; i++)); do
			if [[ ${f__line[$i]} == *\\ ]]; then
				f__stitch_string+=${f__line[$i]}' '
				((f__stitch_c++))
			else
				if (( $i > 0 )); then
					if [[ ${f__line[$[$i-1]]} == *\\ ]]; then
						f__stitch_string+=${f__line[$i]}
						((f__stitch_c++))
					else
						if (( $filename_auto_stitch == 1 )); then
							f__stitch_string+='\ '
							f__stitch_string+=${f__line[$i]}
							((f__stitch_c++))
						fi
					fi
				fi
				if (( $i == 0 )); then
					if (( $filename_auto_stitch == 1 )); then
						f__stitch_string+='\ '
						f__stitch_string+=${f__line[$i]}
						((f__stitch_c++))
					else
						break
					fi
				fi
			fi
		done
	fi
	if (( $f__stitch_c == 0 )); then
		f__stitch_c=1
		f__stitch_string=${f__line[0]}
	fi
	eval $f__str="'$f__stitch_string'"
	eval $f__count="'$f__stitch_c'"
}

if (( $fl_I_g == 1 )); then
	echo '#!/bin/bash'
fi

while read -r line_raw; do
	if [[ ($line_raw =~ ^$  || -z $line_raw || $line_raw =~ ^# ) ]]; then	# Check if line is empty/null/spaces or starts with '#'
		((line_no++))
		continue				# If so, ignore line, check next line, still add line number though
	fi
	for (( i=0; i < ${#users[@]}; i++ )); do	# Initialise 'users' array
		fl_u_valid_line[$i]=0
		fl_u_checked[$i]=0
	done
	for (( i=0; i < ${#groups[@]}; i++ )); do	# Initialise 'groups' array
		fl_g_valid_line[$i]=0
		fl_g_checked[$i]=0
	done
	char_escape line_raw
	if (( $fl_debug == 1 )); then
		echo "$line_no : $line_raw"
	fi
	i=0
	line=()						# Initialise primary line buffer
	for word in $line_raw; do				# Validate each word in line
		if [[ $word == \#* || $word == '#' ]]; then	# Ignore comments
			# If word starts with '#', stop reading (probably is a comment)
			break
		fi
		line[$i]="$word"                              # Push words to line[]
		((i++))
	done
	if (( $fl_f_list == 0 )) && (( $fl_w_list == 0 )); then
		case ${line[0]} in		# Analyse 1st word
			"@NAME_LIST"	)
					if (( $fl_no == 1 )); then
						echo "$line_no : NO cannot be used with @NAME_LIST"
						c_error=1
						break
					fi
					if !(( $fl_o == 0 )); then
						echo "$line_no : @NAME_LIST : Entries must be outside a ACL block"
						c_error=1
						break
					fi
					fl_o=1
					if (( ${#line[@]} > 3 )); then
						echo "$line_no : @STRAY : Too many operands"
						c_error=1
						break
					fi
					if (( ${#line[@]} < 3 )); then			# Per file, per user
						echo "$line_no : @STRAY : Too few operands"
						c_error=1
						break
					fi
					for (( i=1; i < ${#line[@]}; i++ )); do
						case ${line[$i]} in
						"USR" )	fl_nm_list_ug=0
								if (( fl_o != 1 )); then
									echo "$line_no : @NAME_LIST : USR/GRP specified already"
									c_error=1
									break
								fi
								fl_o=2
							;;
						"GRP" )	fl_nm_list_ug=1
								if (( fl_o != 1 )); then
									echo "$line_no : @NAME_LIST : USR/GRP specified already"
									c_error=1
									break
								fi
								fl_o=2
							;;
						"FILE" )fl_nm_list_ft=0
								if (( fl_o != 2 )); then
									echo "$line_no : @NAME_LIST : FILE must be placed after USR/GRP"
									c_error=1
									break
								fi
								fl_o=3
							;;
						"TEXT" )fl_nm_list_ft=1
								if (( fl_o != 2 )); then
									echo "$line_no : @NAME_LIST : TEXT must be placed after USR/GRP"
									c_error=1
									break
								fi
								fl_o=3
							;;
						* )		echo "$line_no : @NAME_LIST : Invalid operands"
								c_error=1
								break
							;;
						esac
					done
					fl_start_type=5
					fl_nm_list_specified=1
				;;
			"@STRAY" )	if (( $fl_no == 1 )); then
						echo "$line_no : NO cannot be used with @STRAY"
						c_error=1
						break
					fi
					if !(( $fl_o == 0 )); then
						echo "$line_no : @STRAY : Entries must be outside a ACL block"
						c_error=1
						break
					fi
					if (( ${#line[@]} == 1 )); then			# Per file, per user
						echo "$line_no : @STRAY : Too few operands"
						c_error=1
						break
					fi
					for (( i=1; i < ${#line[@]}; i++ )); do
						case ${line[$i]} in
							"NO" )	if !(( $fl_o == 0 )); then
									echo "$line_no : @STRAY : NO should be before any other operands"
									c_error=1
									break
								fi
								if (( $fl_no == 1 )); then
									echo "$line_no : @STRAY : NO cannot be repeated"
									c_error=1
									break
								fi
								fl_no=1
								;;
							RES )
								stray_file_index=0
								fl_o=1
								;;
							USR )	if (( $fl_o == 0 )); then
									echo "$line_no : @STRAY : RES must be specified before USR"
									c_error=1
									break
								else	if (( $fl_o == 2 )); then
										echo "$line_no : @STRAY : USR/GRP can only be specified once"
									fi
								fi
								fl_o=2
								;;
							GRP )	if (( $fl_o == 0 )); then
									echo "$line_no : @STRAY : RES must be specified before USR"
									c_error=1
									break
								else	if (( $fl_o == 2 )); then
										echo "$line_no : @STRAY : USR/GRP can only be specified once"
									fi
								fi
								fl_o=2
								;;
							P )	if !(( $fl_o > 2 )) && !(( $fl_o < 4 )); then
									echo "$line_no : @STRAY : Missing USR before P"
									c_error=1
									break
								fi
								if (( $fl_P == 1 )); then
									echo "$line_no : @STRAY : P cannot be repeated"
									c_error=1
									break
								fi
								fl_P=1
								fl_o=3
								stray_file_index=$i+2
								;;
							D )	if !(( $fl_o > 2 )) && !(( $fl_o < 4 )); then
									echo "$line_no : @STRAY : Missing USR before D"
									c_error=1
									break
								fi
								if (( $fl_D == 1 )); then
									echo "$line_no : @STRAY : D cannot be repeated"
									c_error=1
									break
								fi
								fl_D=1
								fl_o=3
								stray_file_index=$i+2
								;;
							R )	if !(( $fl_o > 2 )) && !(( $fl_o < 4 )); then
									echo "$line_no : @STRAY : Missing USR before R"
									c_error=1
									break
								fi
								if (( $fl_R == 1 )); then
									echo "$line_no : @STRAY : R should not be repeated"
									c_error=1
									break
								fi
								fl_R=1
								fl_o=3
								stray_file_index=$i+1
								;;
							* )	if [[ ${line[$i-1]} == "USR" ]]; then
									for (( j=0; j < ${#users[@]}; j++ )); do
										if [[ ${line[$i]} == ${users[$j]} ]]; then
											fl_u_check=1
											break
										fi
									done
									if [[ ${line[$i]} == "ALL" ]]; then
										echo "$line_no : @STRAY : ALL is disabled"
										c_error=1
										break
									fi
									if (( $fl_u_check == 0 )); then
										echo "$line_no : @STRAY : Invalid user"
										c_error=1
										break
									fi
									fl_stray_c=1
								fi
								if [[ ${line[$i-1]} == "GRP" ]]; then
									for (( j=0; j < ${#groups[@]}; j++)); do
										if [[ ${line[$i]} == ${groups[$j]} ]]; then
											fl_g_check=1
											break
										fi
									done
									if [[ ${line[$i]} == "ALL" ]]; then
										echo "$line_no : @STRAY : ALL is disabled"
										c_error=1
										break
									fi
									if (( $fl_g_check == 0 )); then
										echo "$line_no : @STRAY : Invalid group"
										c_error=1
										break
									fi
									fl_stray_c=1
								fi
								if (( $fl_o != 3 )) && (( $fl_stray_c == 0 )); then
									if (( $fl_no == 0 )); then
										echo "$line_no : @STRAY : Invalid operand"
										c_error=1
										break
									else
										if (( $i != $[${#line[@]}-1] )); then
											echo "$line_no : @STRAY : Invalid operand"
											c_error=1
											break
										fi
									fi
								fi
								if [[ ${line[$i-1]} == "P" ]] || [[ ${line[$i-1]} == "D" ]]; then
									perm_check ${line[$i]} fl_perm_check
									if (( $fl_perm_check == 1 )); then
										echo "$line_no : @STRAY : Invalid permission number"
										c_error=1
										break
									else    if (( $fl_perm_check == 2 )); then
											echo "$line_no : @STRAY : Invalid permission string"
											c_error=1
											break
										fi
									fi
									fl_stray_c=1
								fi
								if (( $fl_o != 3 )) && (( $i == $[${#line[@]}-1] )) && (( $fl_stray_c == 0 )) && (( $fl_no == 0 )); then
									echo "$line_no : @STRAY : Invalid operand"
									c_error=1
									break
								fi
								if (( $fl_o == 3)) && ((  $i == $[${#line[@]}-1] )) && (( $fl_stray_c == 0 )) && (( $fl_no == 0 )); then
									if (( $[$fl_P + $fl_D] == 0 )) && (( $fl_no == 0 )); then
										echo "$line_no : @STRAY : Must specify P or D when NO is not used"
										c_error=1
										break
									fi
									fl_o=0
									fl_P=0
									fl_D=0
									fl_R=0
								fi
								fl_stray_c=0
								;;
						esac
					done
					j=0
					for (( i=$stray_file_index; i < ${#line[@]}; i++ )); do
						stray_file_array[j]=${line[$i]}
						((j++))
					done
					filename_stitch stray_file_array[@] file_name_stitch_string file_name_stitch_c c_error
					if (( $[${#stray_file_array[@]}-$file_name_stitch_c+1] > 1)); then	# too many arguments for permission string/number
						echo "$line_no : file too many arguments"
						c_error=1
						break
					fi
					if (( $fl_o != 0 )) && (( $c_error == 0 )) && (( $fl_no == 0 )); then
						echo "$line_no : @STRAY : Incomplete entry"
						c_error=1
						break
					fi
					fl_o=0
					fl_no=0
					((file_no++))
					((stray_no++))
				;;
			"@CHOWN" )
					if (( $fl_no == 1 )); then
						echo "$line_no : !NO cannot be used with @CHOWN"
						c_error=1
						break
					fi
					if (( $fl_o != 0 )); then
						echo "$line_no : @CHOWN : Inside another structure"
						c_error=1
						break
					fi
					fl_o=1
					if (( ${#line[@]} >  5 )); then
						echo "$line_no : @CHOWN : Too many operands"
						c_error=1
						break
					fi
					if (( ${#line[@]} < 3 )); then
						echo "$line_no : @CHOWN : Too few operands"
						c_error=1
						break
					fi
					for (( i=1; i < ${#line[@]}; i++ )); do
						case ${line[$i]} in
						USER )	if (( $fl_chown_u_c != 0 )); then
									echo "$line_no : @CHOWN : USER cannot be repeated"
									c_error=1
									break
								fi
								fl_o=1
								fl_chown_u_c=1
							;;
						GROUP )	if (( $fl_chown_g_c != 0 )); then
									echo "$line_no : @CHOWN : GROUP cannot be repeated"
									c_error=1
									break
								fi
								fl_o=1
								fl_chown_g_c=1
							;;
						RECUR )	if (( $fl_chown_recur != 0 )); then
									echo "$line_no : @CHOWN : RECUR cannot be repeated"
									c_error=1
									break
								fi
								fl_o=1
								fl_chown_recur=1
							;;
						* )		if [[ ${line[$i-1]} == "USER" ]]; then
									fl_chown_c=1
									fl_chown_u_c=2
								fi
								if [[ ${line[$i-1]} == "GROUP" ]]; then
									fl_chown_c=1
									fl_chown_g_c=2
								fi
								if (( $fl_o == 0 )); then
									echo "$line_no : @CHOWN : No target specified"
									c_error=1
									break
								fi
								if (( $fl_chown_c == 0 )); then
									echo "$line_no : @CHOWN : Invalid operand"
									c_error=1
									break
								fi
								fl_chown_c=0
							;;
						esac
					done
					if (($c_error == 1)); then
						exit
					fi
					if (( $fl_chown_u_c == 1 )) || (( $fl_chown_g_c == 1 )); then
						echo "$line_no : @CHOWN : Missing user/group name"
						c_error=1
						break
					fi
					fl_f_list=1
					fl_f_list_type=1
					end_line_no=$(check_end)
				;;
			"@CHMOD" )
					if (( $fl_no == 1 )); then
						echo "$line_no : !NO cannot be used with @CHMOD"
						c_error=1
						break
					fi
					if (( $fl_o != 0 )); then
						echo "$line_no : @CHMOD : Inside another structure"
						c_error=1
						break
					fi
					fl_o=1
					if (( ${#line[@]} >  3 )); then
						echo "$line_no : @CHMOD : Too many operands"
						c_error=1
						break
					fi
					if (( ${#line[@]} < 2 )); then
						echo "$line_no : @CHMOD : Too few operands"
						c_error=1
						break
					fi
					if [[ ${line[1]} == ^[0-9]+$ ]]; then	# Check if permission number is used
						if (( ${#line[1]} != 3 )); then
							echo "$line_no : @CHMOD : Invalid permission number"
							c_error=1
							break
						fi
						for (( i=0; i < 3; i++ )); do
							if (( ${line[1]:$i:1} > 7 || ${line[1]:$i:1} < 0 )); then
								echo "$line_no : @CHMOD : Invalid permission number"
								c_error=1
								break
							fi
						done
					else
						for (( i=0; i < ${#line[1]}; i++ )); do
							case ${line[1]:$i:1} in
							u )	if (( $fl_o != 1 )); then
									echo "$line_no : @CHMOD : Invalid permission string"
									c_error=1
									break
								fi
								fl_o=2
								;;
							g )	if (( $fl_o != 1 )); then
									echo "$line_no : @CHMOD : Invalid permission string"
									c_error=1
									break
								fi
								fl_o=2
								;;
							o )	if (( $fl_o != 1 )); then
									echo "$line_no : @CHMOD : Invalid permission string"
									c_error=1
									break
								fi
								fl_o=2
								;;
							a )	if (( $fl_o != 1 )); then
									echo "$line_no : @CHMOD : Invalid permission string"
									c_error=1
									break
								fi
								fl_o=2
								;;
							= )	if (( $fl_o != 2 )); then
									echo "$line_no : @CHMOD : Invalid permission string"
									c_error=1
									break
								fi
								fl_o=3
								;;
							+ )	if (( $fl_o != 2 )); then
									echo "$line_no : @CHMOD : Invalid permission string"
									c_error=1
									break
								fi
								fl_o=3
								;;
							- )	if (( $fl_o != 2 )); then
									echo "$line_no : @CHMOD : Invalid permission string"
									c_error=1
									break
								fi
								fl_o=3
								;;
							r )	if (( $fl_o < 3 )); then
									echo "$line_no : @CHMOD : Invalid permission string"
									c_error=1
									break
								fi
								fl_o=4
								;;
							w )	if (( $fl_o < 3 )); then
									echo "$line_no : @CHMOD : Invalid permission string"
									c_error=1
									break
								fi
								fl_o=4
								;;
							x )	if (( $fl_o < 3 )); then
									echo "$line_no : @CHMOD : Invalid permission string"
									c_error=1
									break
								fi
								fl_o=4
								;;
							, )	if (( $fl_o < 3 )); then
									echo "$line_no : @CHMOD : Invalid permission string"
									c_error=1
									break
								fi
								fl_o=1
								;;
							* )	echo "$line_no : @CHMOD : Invalid permission string"
								c_error=1
								break
								;;
							esac
						done
					fi
					if (( ${#line[@]} == 3 )); then
						if [[ ${line[2]} == "RECUR" ]]; then
							if (( $fl_chown_recur != 0 )); then
								echo "$line_no : @CHMOD : RECUR cannot be repeated"
								c_error=1
								break
							fi
							fl_chmod_recur=1
						else
							echo "$line_no : @CHMOD : Invalid operand"
							c_error=1
							break
						fi
					fi
					fl_f_list=1
					fl_f_list_type=2
					end_line_no=$(check_end)
				;;
			"@CHATTR" )
					if (( $fl_no == 1 )); then
						echo "$line_no : !NO cannot be used with @CHATTR"
						c_error=1
						break
					fi
					if (( $fl_o != 0 )); then
						echo "$line_no : @CHATTR : Inside another structure"
						c_error=1
						break
					fi
					fl_o=1
					if (( ${#line[@]} >  6 )); then
						echo "$line_no : @CHATTR : Too many operands"
						c_error=1
						break
					fi
					if (( ${#line[@]} < 2 )); then
						echo "$line_no : @CHATTR : Too few operands"
						c_error=1
						break
					fi
					for (( i=1; i < $[${#line[@]}-1]; i++ )); do
						case ${line[$i]} in
						RECUR )		if (( $fl_chattr_recur == 1 )); then
										echo "$line_no : @CHATTR : RECUR repeated"
										c_error=1
										break
									fi
									fl_chattr_recur=1
							;;
						VERBOSE )	if (( $fl_chattr_verbose == 1 )); then
										echo "$line_no : @CHATTR : VERBOSE repeated"
										c_error=1
										break
									fi
									fl_chattr_verbose=1
							;;
						VERSION )	if (( $fl_chattr_version == 1 )); then
										echo "$line_no : @CHATTR : VERSION repeated"
										c_error=1
										break
									fi
									fl_chattr_version=1
							;;
						* )			if [[ ${line[$i-1]} == "VERSION" ]]; then
										chattr_version_no=${line[$i]}
										fl_chattr_version_c=1
										if ! [[ $chattr_version_no =~ ^[0-9]+$ ]]; then
											echo "$line_no : @CHATTR : Invalid version number"
											c_error=1
											break
										fi
									else
										echo "$line_no : @CHATTR : Invalid operand"
										c_error=1
										break
									fi
							;;
						esac
					done
					if (( $c_error == 1 )); then break; fi
					if (( $fl_chattr_version == 1 )) && (( $fl_chattr_version_c == 0 )); then
						echo "$line_no : @CHATTR : Missing version number"
						c_error=1
						break
					fi
					for (( i=0; i < ${#line[$[${#line[@]}-1]]}; i++ )); do
						case ${line[$[${#line[@]}-1]]:$i:1} in
						+ )	if (( $fl_o != 1 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							fl_o=2
							;;
						- )	if (( $fl_o != 1 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							fl_o=2
							;;
						= )	if (( $fl_o != 1 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							fl_o=2
							;;
						a )	if (( $fl_o != 2 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							;;
						c )	if (( $fl_o != 2 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							;;
						d )	if (( $fl_o != 2 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							;;
						e )	if (( $fl_o != 2 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							;;
						i )	if (( $fl_o != 2 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							;;
						j )	if (( $fl_o != 2 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							;;
						s )	if (( $fl_o != 2 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							;;
						t )	if (( $fl_o != 2 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							;;
						u )	if (( $fl_o != 2 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							;;
						A )	if (( $fl_o != 2 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							;;
						D )	if (( $fl_o != 2 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							;;
						S )	if (( $fl_o != 2 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							;;
						T )	if (( $fl_o != 2 )); then
								echo "$line_no : @CHATTR : Invalid attribute string"
								c_error=1
								break
							fi
							;;
						* )	echo "$line_no : @CHATTR : Invalid attribute string"
							c_error=1
							break
							;;
						esac
					done
					fl_f_list=1
					fl_f_list_type=3
					end_line_no=$(check_end)
				;;
			"@APPEND" )	if (( $fl_no == 1 )); then
							echo "$line_no : !NO cannot be used with @APPEND"
							c_error=1
							break
						fi
						if (( $fl_o != 0 )); then
							echo "$line_no : @APPEND : Inside another structure"
							c_error=1
							break
						fi
						fl_o=1
						if (( ${#line[@]} > 1 )); then
							echo "$line_no : @APPEND : Too many operands"
							c_error=1
							break
						fi
						if (( $[$fl_insert_specified + $fl_replace_specified] != 0 )); then
							echo "$line_no : @APPEND : Cannot be used with @INSERT or @REPLACE"
							c_error=1
							break
						fi
						if (( $fl_append_specified == 1 )); then
							echo "$line_no : @APPEND : Cannot be repeated"
							c_error=1
							break
						fi
						fl_append_specified=1
						fl_start_type=1
						fl_w_list_type=0
				;;
			"@INSERT" )	if (( $fl_no == 1 )); then
							echo "$line_no : !NO cannot be used with @INSERT"
							c_error=1
							break
						fi
						if (( $fl_o != 0 )) && (( $fl_insert_specified == 0 )); then
							echo "$line_no : @INSERT : Inside another structure"
							c_error=1
							break
						fi
						fl_o=1
						if (( ${#line[@]} >  1 )); then
							echo "$line_no : @INSERT : Too many operands"
							c_error=1
							break
						fi
						if (( $fl_insert_block_completed == 0 )); then
							echo "$line_no : @INSERT : Missing operand in previous statement"
							c_error=1
							break
						fi
						if (( $[$fl_append_specified + $fl_replace_specified] != 0 )); then
							echo "$line_no : @INSERT : Cannot be used with @APPEND or @REPLACE"
							c_error=1
							break
						fi
						fl_insert_block_completed=0
						fl_insert_specified=1
						fl_start_type=2
						fl_w_list_type=1
						fl_insert_line=0
						fl_insert_after=0
						((fl_insert_index++))
						((fl_insert_index_after++))
						after_line_no=$(check_after)
				;;
			"@REPLACE" )	if (( $fl_no == 1 )); then
							echo "$line_no : !NO cannot be used with @REPLACE"
							c_error=1
							break
						fi
						if (( $fl_o != 0 )) && (($fl_replace_specified == 0)); then
							echo "$line_no : @REPLACE : Inside another structure"
							c_error=1
							break
						fi
						fl_o=1
						if (( ${#line[@]} >  1 )); then
							echo "$line_no : @REPLACE : Too many operands"
							c_error=1
							break
						fi
						if (( $fl_replace_block_completed == 0 )); then
							echo "$line_no : @REPLACE : Missing operand in previous statement"
							c_error=1
							break
						fi
						if (( $[$fl_append_specified + $fl_insert_specified] != 0 )); then
							echo "$line_no : @REPLACE : Cannot be used with @APPEND or @INSERT"
							c_error=1
							break
						fi
						fl_replace_block_completed=0
						fl_replace_specified=1
						fl_start_type=3
						fl_w_list_type=2
						fl_replace_with=0
						((fl_replace_index++))
						((fl_replace_index_after++))
						with_line_no=$(check_with)
				;;
			"@COMMAND" )	if (( $fl_no == 1 )); then
							echo "$line_no : !NO cannot be used with @COMMAND"
							c_error=1
							break
						fi
						if (( $fl_o != 0 )); then
							echo "$line_no : @COMMAND : Inside another structure"
							c_error=1
							break
						fi
						fl_o=0
						if (( ${#line[@]} >  1 )); then
							echo "$line_no : @COMMAND t: Too many operands"
							c_error=1
							break
						fi
						fl_w_list_type=3
						fl_command_specified=1
						fl_start_type=4
						end_line_no=$(check_end)
				;;
			"!NO" )	if ! (( $fl_o == 0 )); then
						echo "$line_no : Missing <END before current line"
						c_error=1	# Error detected
						break
					fi
					if (( $fl_no == 1 )); then
						echo "$line_no : !NO cannot be repeated"
						c_error=1	# Error detected
						break
					fi
					if (( ${#line[@]} > 2 )); then		# Syntax checking
						echo "$line_no : !NO - too many arguments"
						c_error=1	# Error detected
						break
					fi
					if (( ${#line[@]} == 2 )); then
						if ! [[ ${line[1]} == "ALL" ]]; then
							echo "$line_no : !NO - only optional operand is ALL"
							c_error=1
							break
						fi
					fi
					fl_no=1			# flag_no=1 indicates '!NO' has been specified once
					# No modification of fl_o, since !NO is optional
				;;
			"@RESTRICT" )	if (( $fl_o != 0 )) && (( $fl_o != 1 )); then
							# Check if previous operand is either '<END' or '@RESTRICT',
							# since '@RESTRICT' can be specified twice
							echo "$line_no : Missing <END before current line"
							c_error=1	# Error detected
							break
						fi
						fl_o=1			# fl_o=1 indicates '@RESTRICT' has been specified once
						fl_e=0
						fl_f_list_type=0
						fl_restrict_specified=1
						case ${line[1]} in	# Analyse 2nd word, after '@RESTRICT'
						USER )	if (( ${#line[@]} == 2 )); then
								echo "$line_no : @RESTRICT : USER specifiy atleast one user"
								c_error=1
								break
							fi
							if (( $fl_r_u == 1 )); then
								echo "$line_no : You can only specify @RESTRICT USER once in each block"
								c_error=1
								break
							fi
							fl_r_u=1
							if (( ${#line[@]} > $[2+${#users[@]}] )); then
								# Even if the user types ALL, it shouldn't exceed the limit
								# This will still be positive if you use ALL, but have an empty users array
								echo "$line_no : @RESTRICT : USER - too many users"
								c_error=1
								break
							fi
							for (( i=2; i < ${#line[@]}; i++ )); do
								if [[ ${line[$i]} == "ALL" ]]; then	# Check if 'ALL' or any user are specified at the same time
									fl_all=1
								else
									fl_others=1
								fi
								if (( $fl_all == 1 )) && (( $fl_others == 1 )); then
									echo "$line_no : No other users should be specified with ALL"
									c_error=1 # Error
									break
								fi
							done
							for (( i=0; i < ${#users[@]}; i++ )); do
								fl_u[$i]=0
								fl_u_checked[$i]=0
							done
							if (( $fl_all == 0 )) && (( $fl_others == 1 )); then	# Only users, no ALL
								# If ALL is not specified, check specified users
								for (( i=2; i < ${#line[@]}; i++ )); do		# Check if users are valid elements of users array
									for (( j=0; j < ${#users[@]}; j++ )); do
										if [[ ${line[$i]} == ${users[$j]} ]] && !(( ${fl_u_checked[$j]} == 1 )); then
											fl_u_valid_line[$[$i-2]]=1
											fl_u_checked[$j]=1	# Set 1 to indicate user is checked
											#echo "$line_no : ignored user : ${users[$j]}"
										else	if [[ ${line[$i]} == ${users[$j]} ]] && (( ${fl_u_checked[$j]} == 1 )); then
												echo "$line_no : user ${users[$j]} is repeated"
												((c_warn++))	# Warning
												fl_u_valid_line[$[$i-2]]=1
												# Don't set fl_u_checked since it's repeated
											fi
										fi
									done
								done
								for (( i=2; i < ${#line[@]}; i++ )); do		# Report invalid users
									if (( ${fl_u_valid_line[$[$i-2]]} == 0 )); then
										echo "$line_no : @RESTRICT USER - user ${line[$i]} is not present in users array"
										c_error=1
										break
									fi
								done
								if (( $c_error == 1)); then break; fi
							fi
							if [[ ${line[2]} == "ALL" ]]; then		# If ALL is specified, mark all users
								for (( j=0; j < ${#users[@]}; j++ )); do
									fl_u[$j]=1	# Set 1 to mark user will be selected
								done
							else						# If not, then mark individual users
								for (( i=2; i < ${#line[@]}; i++ )); do
									for (( j=0; j < ${#users[@]}; j++ )); do
										if [[ ${line[$i]} == ${users[$j]} ]] && !(( ${fl_u[$j]} == 1 )); then
											fl_u[$j]=1	# Set 1 to mark user will be selected
										fi
									done
								done
							fi
							;;
						GROUP ) if (( ${#line[@]} == 2 )); then
								echo "$line_no : @RESTRICT GROUP Specifiy atleast one group"
								c_error=1
								break
							fi
							if (( $fl_r_g == 1 )); then
								echo "$line_no : You can only specify @RESTRICT GROUP once in each block"
								c_error=1	# Error
								break
							fi
							fl_r_g=1
							if (( ${#line[@]} > $[2+${#groups[@]}] )); then
								# Even if  ALL is specified, it shouldn't exceed the limit
								# This will still be positive if you use ALL, but have an empty groups array
								echo "$line_no : @RESTRICT GROUP - too many groups"
								c_error=1	# Error
								break
							fi
							for (( i=2; i < ${#line[@]}; i++ )); do
								if [[ ${line[$i]} == "ALL" ]]; then	# Check if 'ALL' or any group exist at the same time
									fl_all=1
								else
									fl_others=1
								fi
								if (( $fl_all == 1 )) && (( $fl_others == 1 )); then
									echo "$line_no : No other groups should be specified with ALL"
									c_error=1 # Error
									break
								fi
							done
							for (( i=0; i < ${#groups[@]}; i++ )); do
								fl_g[$i]=0
								fl_g_checked[$i]=0
							done
							if (( $fl_all == 0 )) && (( $fl_others == 1 )); then	# Only groups, no ALL
								# If ALL is not specified, check specified groups
								for (( i=2; i < ${#line[@]}; i++ )); do		# Check if users are valid elements of users array
									for (( j=0; j < ${#groups[@]}; j++ )); do
										if [[ ${line[$i]} == ${groups[$j]} ]] && !(( ${fl_g_checked[$j]} == 1 )); then
											fl_g_valid_line[$[$i-2]]=1
											fl_g_checked[$j]=1	# Set 1 to indicate user is checked
											#echo "$line_no : ignored user : ${users[$j]}"
										else	if [[ ${line[$i]} == ${groups[$j]} ]] && (( ${fl_g_checked[$j]} == 1 )); then
												echo "$line_no : group ${groups[$j]} is repeated"
												((c_warn++))
												fl_g_valid_line[$[$i-2]]=1
												# Don't set fl_g_checked since it's repeated
											fi
										fi
									done
								done
								for (( i=2; i < ${#line[@]}; i++ )); do		# Report invalid users
									if (( ${fl_g_valid_line[$[$i-2]]} == 0 )); then
										echo "$line_no : @RESTRICT GROUP - group ${line[$i]} is not present in groups array"
										c_error=1
										break
									fi
								done
							fi
							if [[ ${line[2]} == "ALL" ]]; then		# If ALL is specified, mark all groups
								for (( j=0; j < ${#groups[@]}; j++ )); do
									fl_g[$j]=1	# Set 1 to mark user will be selected
								done
							else						# If not, then mark individual groups
								for (( i=2; i < ${#line[@]}; i++ )); do
									for (( j=0; j < ${#groups[@]}; j++ )); do
										if [[ ${line[$i]} == ${groups[$j]} ]] && !(( ${fl_g[$j]} == 1 )); then
											fl_g[$j]=1	# Set 1 to mark user will be selected
										fi
									done
								done
							fi
							;;
						* )	echo "$line_no : @RESTRICT - missing target"
							c_error=1
							break
							;;
						esac
						fl_start_type=0
				;;
			"@EXCLUDE" )	if (( $fl_o == 0 )); then
						echo "$line_no : Missing @RESTRICT before current line"
						c_error=1
						break
					else	if (( $fl_o == 2 )); then
							echo "$line_no : +PERM is before @EXCLUDE"
							c_error=1
							break
						fi
					fi			# fl_o = 1 is accepted
					case ${line[1]} in
					USER )	if (( ${#line[@]} == 2 )); then
							echo "$line_no : @EXCLUDE USER Specifiy atleast one user"
							c_error=1
							break
						fi
						if (( $fl_e_u == 1 )); then
							echo "$line_no : You can only specify @EXCLUDE USER once in each block"
							c_error=1
							break
						fi
						fl_e_u=1
						for (( i=2; i < ${#line[@]}; i++ )); do
							if [[ ${line[$i]} == "ALL" ]]; then
								echo "$line_no : @EXCLUDE USER ALL is not allowed"
								c_error=1
								break				# Break first loop
							fi
						done
						if (( $c_error == 1 )); then break; fi		# Break second loop
						if [[ ${#line[@]} > $[2+${#users[@]}] ]]; then
							echo "$line_no : @EXCLUDE USER - too many users"
							c_error=1
							break
						fi
						# Since ALL is not present, check specified users
						for (( i=2; i < ${#line[@]}; i++ )); do		# Check if users are valid elements of users array
							for (( j=0; j < ${#users[@]}; j++ )); do
								if [[ ${line[$i]} == ${users[$j]} ]] && !(( ${fl_u_checked[$j]} == 1 )); then
									fl_u_valid_line[$[$i-2]]=1
									fl_u_checked[$j]=1	# Set 1 to indicate user is checked
									#echo "$line_no : ignored user : ${users[$j]}"
								else	if [[ ${line[$i]} == ${users[$j]} ]] && (( ${fl_u_checked[$j]} == 1 )); then
										echo "$line_no : user ${users[$j]} is repeated"
										((c_warn++))
										fl_u_valid_line[$[$i-2]]=1
										# Don't set fl_u_checked since it's repeated
									fi
								fi
							done
						done
						for (( i=2; i < ${#line[@]}; i++ )); do		# Report invalid users
							if (( ${fl_u_valid_line[$[$i-2]]} == 0 )); then
								echo "$line_no : @RESTRICT USER - user ${line[$i]} is not present in users array"
								c_error=1
								break
							fi
						done
						for (( i=2; i < ${#line[@]}; i++ )); do		# Mark individual users
							for (( j=0; j < ${#users[@]}; j++ )); do
								if [[ ${line[$i]} == ${users[$j]} ]] && !(( ${fl_u[$j]} == 0 )); then
									fl_u[$j]=0	# Set 0 to mark user will not be selected
								fi
							done
						done
						for (( i=0; i < ${#users[@]}; i++ )); do
							if (( ${fl_u[$i]} == 1 )); then
								fl_u_check=1
								break
							fi
						done
						if (( $fl_u_check == 0 )); then
							echo "$line_no : Cannot exclude all users previously specified"
							c_error=1
							break
						fi
						;;
					GROUP ) if (( ${#line[@]} == 2 )); then
							echo "$line_no : @EXCLUDE GROUP Specifiy atleast one group"
							c_error=1
							break
						fi
						if (( $fl_e_g == 1 )); then
							echo "$line_no : You can only specify @EXCLUDE GROUP once in each block"
							c_error=1
							break
						fi
						fl_e_g=1
						for (( i=2; i < ${#line[@]}; i++ )); do
							if [[ ${line[$i]} == "ALL" ]]; then
								echo "$line_no : @EXCLUDE GROUP ALL is not allowed"
								c_error=1
								break				# Break first loop
							fi
						done
						if (( $c_error == 1 )); then break; fi		# Break second loop
						if [[ ${#line[@]} > $[2+${#groups[@]}] ]]; then
							echo "$line_no : @EXCLUDE GROUP - too many groups"
							c_error=1
							break
						fi
						# Since ALL is not present, check specified groups
						for (( i=2; i < ${#line[@]}; i++ )); do		# Check if groups are valid elements of groups array
							for (( j=0; j < ${#groups[@]}; j++ )); do
								if [[ ${line[$i]} == ${groups[$j]} ]] && !(( ${fl_g_checked[$j]} == 1 )); then
									fl_g_valid_line[$[$i-2]]=1
									fl_g_checked[$j]=1	# Set 1 to indicate group is checked
									#echo "$line_no : ignored group : ${groups[$j]}"
								else	if [[ ${line[$i]} == ${groups[$j]} ]] && (( ${fl_g_checked[$j]} == 1 )); then
										echo "$line_no : group ${groups[$j]} is repeated"
										((c_warn++))
										fl_g_valid_line[$[$i-2]]=1
										# Don't set fl_g_checked since it's repeated
									fi
								fi
							done
						done
						for (( i=2; i < ${#line[@]}; i++ )); do		# Report invalid users
							if (( ${fl_g_valid_line[$[$i-2]]} == 0 )); then
								echo "$line_no : @RESTRICT GROUP - group flag 1 ${line[$i]} is not present in groups array"
								c_error=1
								break
							fi
						done
						for (( i=2; i < ${#line[@]}; i++ )); do		# Mark individual groups
							for (( j=0; j < ${#groups[@]}; j++ )); do
								if [[ ${line[$i]} == ${groups[$j]} ]] && !(( ${fl_g[$j]} == 0 )); then
									fl_g[$j]=0	# Set 0 to mark group will not be selected
								fi
							done
						done
						for (( i=0; i < ${#groups[@]}; i++ )); do
							if (( ${fl_g[$i]} == 1 )); then
								fl_g_check=1
								break
							fi
						done
						if (( $fl_g_check == 0 )); then
							echo "$line_no : Cannot exclude all groups previously specified"
							c_error=1
							break
						fi
						;;
					* )	echo "$line_no : @EXCLUDE - missing target"; c_error=1; break
						;;
					esac
					# No modification of fl_o, since @EXCLUDE is optional
				;;
			"+PERM" )		if (( $fl_no == 0 )); then
						if (( $fl_o == 0 )); then
							echo "$line_no : Missing @RESTRICT before current line"
							c_error=1
							break
						else	if (( $fl_perm == 1 )); then
								echo "$line_no : +PERM should not be repeated"
								c_error=1
								break
							fi
						fi			# fl_o = 1 is accepted
						fl_o=2
						fl_perm=1
						if (( ${#line[@]} > 2 )); then
							echo "$line_no : +PERM - too many parameters"
							c_error=1
							break
						else	if (( ${#line[@]} == 1 )); then
								echo "$line_no : +PERM - missing permission"
								c_error=1
								break
							fi
						fi
						perm_check ${line[1]} fl_perm_check
						if (( $fl_perm_check == 1 )); then
							echo "$line_no : Invalid permission number"
							c_error=1
							break
						else    if (( $fl_perm_check == 2 )); then
								echo "$line_no : Invalid permission string"
								c_error=1
								break
							fi
						fi
					fi
				;;
			"+DPERM" )		if (( $fl_no == 0 )); then
						if (( $fl_o == 0 )); then
							echo "$line_no : Missing @RESTRICT before current line"
							c_error=1
							break
						else	if (( $fl_dperm == 1 )); then
								echo "$line_no : +DPERM should not be repeated"
								c_error=1
								break
							fi
						fi			# fl_o = 1 is accepted
						fl_o=2
						fl_dperm=1
						if (( ${#line[@]} > 2 )); then
							echo "$line_no : +DPERM - too many parameters"
							c_error=1
							break
						else	if (( ${#line[@]} == 1 )); then
								echo "$line_no : +DPERM - missing permission"
								c_error=1
								break
							fi
						fi
						perm_check ${line[1]} fl_perm_check
						if (( $fl_perm_check == 1 )); then
							echo "$line_no : Invalid permission number"
							c_error=1
							break
						else    if (( $fl_perm_check == 2 )); then
								echo "$line_no : Invalid permission string"
								c_error=1
								break
							fi
						fi
					fi
				;;
			"+RECUR" )	if (( $fl_no == 0 )); then
						if (( $fl_o == 0 )); then
							echo "$line_no : Missing @RESTRICT before current line"
							c_error=1
							break
						else	if (( $fl_o == 1 )); then
									echo "$line_no : Missing +PERM/+DPERM before current line"
									c_error=1
									break
								fi
						fi
					else	if !(( $fl_o == 1 )); then
								echo "$line_no : Missing @RESTRICT before current line"
								c_error=1
								break
							fi
					fi
					if (( ${#line[@]} > 1 )); then		# Syntax checking
						echo "$line_no : +RECUR - too many arguments"
						c_error=1	# Error detected	
						break
					fi
					fl_recur=1
				;;
			">START" )
					if (( $fl_start_type == 0 )); then
						if (( $[$fl_perm + $fl_dperm ] == 0 )) && (( $fl_no == 0 )); then
							echo "$line_no : ACL : Must specify +PERM or +DPERM when !NO is not used"
							c_error=1
							break
						fi
						if (( $fl_no == 0 )); then
							if (( $fl_o == 0 )); then
								echo "$line_no : Missing @RESTRICT before current line"
								c_error=1
								break
							else	if (( $fl_o == 1 )); then
									echo "$line_no : Missing +PERM/+DPERM before current line"
									c_error=1
									break
								fi
							fi
						else	if !(( $fl_o == 1 )); then
								echo "$line_no : Missing @RESTRICT before current line"
								c_error=1
								break
							fi
						fi
						fl_o=3
						if (( $[$fl_perm + $fl_dperm ] == 0 )) && (( $fl_no == 0 )); then
							echo "$line_no : ACL : Must specify P or D when !NO is not used"
							c_error=1
							break
						fi
						if (( ${#line[@]} > 1 )); then		# Syntax checking
							echo "$line_no : >START - too many arguments"
							c_error=1	# Error detected	
							break
						fi
						fl_f_list=1
						end_line_no=$(check_end)
					fi
					if (( $fl_start_type == 1 )); then
						if (( ${#line[@]} > 1 )); then		# Syntax checking
							echo "$line_no : >START - too many arguments"
							c_error=1	# Error detected	
							break
						fi
						end_line_no=$(check_end)
						fl_o=2
						fl_f_list=1
						fl_f_list_type=4
					fi
					if (( $fl_start_type == 2 )); then
						if (( ${#line[@]} > 1 )); then		# Syntax checking
							echo "$line_no : >START - too many arguments"
							c_error=1	# Error detected	
							break
						fi
						if (( $[$fl_insert_line + $fl_insert_after] == 0 )); then
							echo "$line_no : @INSERT : Please specify @LINE or @AFTER"
							c_error=1
							break
						fi
						end_line_no=$(check_end)
						fl_f_list=1
						fl_f_list_type=5
					fi
					if (( $fl_start_type == 3 )); then
						if (( ${#line[@]} > 1 )); then		# Syntax checking
							echo "$line_no : >START - too many arguments"
							c_error=1	# Error detected	
							break
						fi
						if (( $fl_replace_block_completed != 1 )); then
							echo "$line_no : @REPLACE : Missing @WITH"
							c_error=1
							break
						fi
						end_line_no=$(check_end)
						fl_f_list=1
						fl_f_list_type=6
					fi
					if (( $fl_start_type == 4 )); then
						:
					fi
					if (( $fl_start_type == 5 )); then
						if (( $fl_nm_list_ft == 0 )); then
							fl_f_list=1
							fl_f_list_type=7
						else
							fl_nm_list_c=0
							fl_w_list_type=4
						fi
						end_line_no=$(check_end)
					fi
				;;
			* )	    if (( $[$fl_append_specified + $fl_insert_specified + $fl_replace_specified + $fl_command_specified + $fl_nm_list_specified] == 0 )); then
						if (( $fl_restrict_specified == 0 )); then
							echo "$line_no : Missing operand"
							c_error=1
							break
						else
							echo "$line_no : Invalid operand"
							c_error=1
							break
						fi
					fi
					if (( $fl_w_list_type == 0 )); then
						((append_text_no++))
					fi
					if (( $fl_w_list_type == 1 )); then
						if (( $line_no != $after_line_no )); then
							case ${line[0]} in
							"@LINE" )	if (( $fl_insert_line == 1 )); then
											echo "$line_no : @INSERT : @LINE cannot be repeated"
											c_error=1
											break
										fi
										fl_insert_line=1
										if (( ${#line[@]} > 2 )); then
											echo "$line_no : @INSERT : @LINE too many operands"
											c_error=1
											break
										fi
										if (( ${#line[@]} < 2 )); then
											echo "$line_no : @INSERT : @LINE missing line number"
											c_error=1
											break
										fi
										if ! [[ ${line[1]} =~ ^[0-9]+$ ]]; then	# Check if permission number is used
											echo "$line_no : @INSERT : @LINE invalid number"
											c_error=1
											break
										fi
										fl_insert_block_completed=1
								;;
							* )		if (( $fl_insert_line == 1 )); then
										echo "$line_no : @INSERT : There should be no text after @LINE"
										c_error=1
										break
									fi
									((insert_text_no++))
								;;
							esac
						else
							if (( $fl_insert_after == 1 )); then
								echo "$line_no : @INSERT: @AFTER cannot be repeated"
								c_error=1
								break
							fi
							fl_insert_after=1
							if (( ${#line[@]} > 1 )); then
								echo "$line_no : @INSERT : @AFTER too many operands"
								c_error=1
								break
							fi
							fl_insert_block_completed=1
						fi
						if (( $[$fl_insert_line + $fl_insert_after] == 2 )); then
							echo "$line_no : @INSERT : @LINE and @AFTER cannot be used together"
							c_error=1
							break
						fi
					fi
					if (( $fl_w_list_type == 2 )); then
						if (( $line_no != $with_line_no )); then
							if (( $fl_replace_block_completed == 0 )); then
								((replace_old_text_no++))
							else
								((replace_new_text_no++))
							fi
						else
							if (( ${#line[@]} > 1 )); then
								echo "$line_no : @WITH too many operands"
								c_error=1
								break
							fi
							if (($fl_replace_block_completed == 1 )); then
								echo "$line_no : @REPLACE : @WITH must be used after @REPLACE"
								c_error=1
								break
							fi
							fl_replace_block_completed=1
						fi
					fi
					if (( $fl_w_list_type == 3 )); then
						if (( $line_no == $end_line_no )); then
							fl_o=0
							fl_f_list=0
							fl_f_list_type=0
							fl_start_type=0
							fl_w_list=0
							fl_w_list_type=0
							((cmd_no++))
						fi
						((cmd_line_no++))
					fi
					if (( $fl_w_list_type == 4 )); then
						if (( $line_no != $end_line_no )); then
							if (( fl_nm_list_ug == 0 )); then
								for ((j=0; j<${#line[@]}; j++)); do
									users[$fl_nm_list_c]=${line[$j]}
									((nm_list_user_no++))
									((fl_nm_list_c++))
								done
							else
								for ((j=0; j<${#line[@]}; j++)); do
									groups[$fl_nm_list_c]=${line[$j]}
									((nm_list_group_no++))
									((fl_nm_list_c++))
								done
							fi
						else
							fl_o=0
							fl_f_list=0
							fl_f_list_type=0
							fl_start_type=0
							fl_w_list=0
							fl_w_list_type=0
							fl_nm_list_c=0
							fl_nm_list_specified=0
							((nm_list_no++))
							for (( i=0; i < ${#users[@]}; i++ )); do
								fl_u[$i]=0
							done
							for (( i=0; i < ${#groups[@]}; i++ )); do
								fl_g[$i]=0
							done
						fi
					fi
				;;
		esac
	else
		if (( $fl_f_list_type == 0 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				if ! (( $fl_o == 3 )); then
					echo "$line_no : ACL : Missing >START before current line"
					c_error=1
					break
				fi
				filename_stitch line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $[${#line[@]}-$file_name_stitch_c+1] == 2 )); then	# too many arguments for permission string/number
					echo "$line_no : ACL : file too little arguments for additional permissions"
					c_error=1
					break
				fi
				if (( $[${#line[@]}-$file_name_stitch_c+1] > 4)); then	# too many arguments for permission string/number
					echo "$line_no : ACL : file too many arguments"
					c_error=1
					break
				fi
				if (( $[${#line[@]}-$file_name_stitch_c+1] == 3)); then
					perm_check ${line[$[$file_name_stitch_c]]} fl_perm_check
					if (( fl_perm_check == 1 )); then
						echo "$line_no : ACL : Invalid permission number"
						c_error=1
						break
					else    if (( fl_perm_check == 2 )); then
							echo "$line_no : ACL : Invalid permission string"
							c_error=1
							break
						fi
					fi
					if (( ${#line[$[$file_name_stitch_c+1]]} > 3 )); then
						echo "$line_no : ACL : file invalid flags"
						c_error=1
						break
					fi
					for (( i=0; i < ${#line[$[$file_name_stitch_c+1]]}; i++ )); do
						case ${line[$[$file_name_stitch_c+1]]:$i:1} in
							P )	if (( $fl_P == 1 )); then
									echo "$line_no : ACL : file flag P should not be repeated"
									c_error=1
									break
								fi
								if (( $fl_D == 1 )); then
									echo "$line_no : ACL : file flag P should go before flag D"
									c_error=1
									break
								fi
								if (( $fl_R == 1 )); then
									echo "$line_no : ACL : file flag P should go before flag R"
									c_error=1
									break
								fi
								fl_P=1
								;;
							D )	if (( $fl_D == 1 )); then
									echo "$line_no : ACL : file flag D should not be repeated"
									c_error=1
									break
								fi
								if (( $fl_R == 1 )); then
									echo "$line_no : ACL : file flag D should go before flag R"
									c_error=1
									break
								fi
								fl_D=1
								;;
							R )	if (( $fl_R == 1 )); then
									echo "$line_no : ACL : file flag R should not be repeated"
									c_error=1
									break
								fi
								fl_R=1
								;;
							* )	echo "$line_no : ACL : flag invalid flags"
								c_error=1
								break
								;;
						esac
					done
				else	if (( $[${#line[@]}-$file_name_stitch_c+1] == 4)); then
						perm_check ${line[$file_name_stitch_c]} fl_perm_check
						if (( fl_perm_check == 1 )); then
							echo "$line_no : ACL : Invalid permission number"
							c_error=1
							break
						else    if (( fl_perm_check == 2 )); then
								echo "$line_no : ACL : Invalid permission string"
								c_error=1
								break
							fi
						fi
						perm_check ${line[$[$file_name_stitch_c+1]]} fl_perm_check
						if (( fl_perm_check == 1 )); then
							echo "$line_no : ACL : Invalid permission number"
							c_error=1
							break
						else    if (( fl_perm_check == 2 )); then
								echo "$line_no : ACL : Invalid permission string"
								c_error=1
								break
							fi
						fi
						if (( ${#line[$[$file_name_stitch_c+1]]} > 3 )); then
							echo "$line_no : ACL : file invalid flags"
							c_error=1
							break
						fi
						for (( i=0; i < ${#line[$[$file_name_stitch_c+2]]}; i++ )); do
							case ${line[$[$file_name_stitch_c+2]]:$i:1} in
								P )	if (( $fl_P == 1 )); then
										echo "$line_no : ACL : file flag P should not be repeated"
										c_error=1
										break
									fi
									if (( $fl_D == 1 )); then
										echo "$line_no : ACL : file flag P should go before flag D"
										c_error=1
										break
									fi
									if (( $fl_R == 1 )); then
										echo "$line_no : ACL : file flag P should go before flag R"
										c_error=1
										break
									fi
									fl_P=1
									;;
								D )	if (( $fl_D == 1 )); then
										echo "$line_no : ACL : file flag D should not be repeated"
										c_error=1
										break
									fi
									if (( $fl_R == 1 )); then
										echo "$line_no : ACL : file flag D should go before flag R"
										c_error=1
										break
									fi
									fl_D=1
									;;
								R )	if (( $fl_R == 1 )); then
										echo "$line_no : ACL : file flag R should not be repeated"
										c_error=1
										break
									fi
									fl_R=1
									;;
								* )	echo "$line_no : ACL : flag invalid flags"
									c_error=1
									break
									;;
							esac
						done
					fi
				fi
				((file_no++))
				fl_P=0
				fl_D=0
				fl_R=0
			else					# If it's the last '<END', then do standard syntax checking for '<END'
				if (( ${#line[@]} > 1 )); then
					echo "$line_no : ACL : Too many operands after <END"
					c_error=1
					break
				fi
				if !(( $fl_o == 3 )); then
					echo "$line_no : ACL : Missing >START before line"
					c_error=1
					break
				fi      # fl_o = 3 is accepted
				((acl_block_no++))
				fl_o=0
				# The following flags are used for the whole block
				fl_r_u=0
				fl_r_g=0
				fl_e_u=0
				fl_e_g=0
				fl_no=0
				fl_f_list=0
				fl_perm=0
				fl_dperm=0
				fl_recur=0
				fl_restrict_specified=0
			fi
		fi
		if (( $fl_f_list_type == 1 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				filename_stitch line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $[${#line[@]}-$file_name_stitch_c+1] > 1)); then	# too many arguments for permission string/number
					echo "$line_no : file too many arguments"
					c_error=1
					break
				fi
				((chown_file_no++))
			else					# If it's the last '<END', then do standard syntax checking for '<END'
				if (( ${#line[@]} > 1 )); then
					echo "$line_no : Too many operands after <END"
					c_error=1
					break
				fi
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				fl_chown_u_c=0
				fl_chown_g_c=0
				((chown_no++))
			fi
		fi
		if (( $fl_f_list_type == 2 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				filename_stitch line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $[${#line[@]}-$file_name_stitch_c+1] > 1)); then	# too many arguments for permission string/number
					echo "$line_no : file too many arguments"
					c_error=1
					break
				fi
				((chmod_file_no++))
			else					# If it's the last '<END', then do standard syntax checking for '<END'
				if (( ${#line[@]} > 1 )); then
					echo "$line_no : Too many operands after <END"
					c_error=1
					break
				fi
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				((chmod_no++))
			fi
		fi
		if (( $fl_f_list_type == 3 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				filename_stitch line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $[${#line[@]}-$file_name_stitch_c+1] > 1)); then	# too many arguments for permission string/number
					echo "$line_no : file too many arguments"
					c_error=1
					break
				fi
				((chattr_file_no++))
			else					# If it's the last '<END', then do standard syntax checking for '<END'
				if (( ${#line[@]} > 1 )); then
					echo "$line_no : Too many operands after <END"
					c_error=1
					break
				fi
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				fl_chattr_recur=0
				fl_chattr_verbose=0
				fl_chattr_version=0
				fl_chattr_version_c=0
				chattr_version_no=0
				chattr_string=""
				chattr_arg_string=""
				((chattr_no++))
			fi
		fi
		if (( $fl_f_list_type == 4 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				filename_stitch line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $[${#line[@]}-$file_name_stitch_c+1] > 1)); then	# too many arguments for permission string/number
					echo "$line_no : file too many arguments"
					c_error=1
					break
				fi
				((append_file_no++))
			else					# If it's the last '<END', then do standard syntax checking for '<END'
				if (( ${#line[@]} > 1 )); then
					echo "$line_no : Too many operands after <END"
					c_error=1
					break
				fi
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				fl_start_type=0
				fl_w_list=0
				fl_w_list_type=0
				fl_append_specified=0
				((append_no++))
			fi
		fi
		if (( $fl_f_list_type == 5 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				filename_stitch line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $[${#line[@]}-$file_name_stitch_c+1] > 1)); then	# too many arguments for permission string/number
					echo "$line_no : file too many arguments"
					c_error=1
					break
				fi
				((insert_file_no++))
			else					# If it's the last '<END', then do standard syntax checking for '<END'
				if (( ${#line[@]} > 1 )); then
					echo "$line_no : Too many operands after <END"
					c_error=1
					break
				fi
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				fl_start_type=0
				fl_w_list=0
				fl_w_list_type=0
				fl_insert_specified=0
				fl_insert_line=0
				fl_insert_after=0
				((insert_no++))
			fi
		fi
		if (( $fl_f_list_type == 6 )); then
			if (( $line_no != $end_line_no )); then	# If it's not the last '<END', process it as file name
				filename_stitch line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $[${#line[@]}-$file_name_stitch_c+1] > 1)); then	# too many arguments for permission string/number
					echo "$line_no : file too many arguments"
					c_error=1
					break
				fi
				((replace_file_no++))
			else					# If it's the last '<END', then do standard syntax checking for '<END'
				if (( ${#line[@]} > 1 )); then
					echo "$line_no : Too many operands after <END"
					c_error=1
					break
				fi
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				fl_start_type=0
				fl_w_list=0
				fl_w_list_type=0
				fl_replace_specified=0
				((replace_no++))
			fi
		fi
		if (( $fl_f_list_type == 7 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				filename_stitch line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $[${#line[@]}-$file_name_stitch_c+1] > 1)); then
					echo "$line_no : file too many arguments"
					c_error=1
					break
				fi
				if [ ! -f "$(char_deescape_echo file_name_stitch_string)" ]; then
					echo "$line_no : @NAME_LIST : File does not exist"
					exit
				fi
				while read -r nm_list_line_raw; do
					if [[ ($nm_list_line_raw =~ ^$  || -z $nm_list_line_raw || $nm_list_line_raw =~ ^# ) ]]; then	# Check if line is empty/null/spaces or starts with '#'
						((nm_list_file_line_no++))
						continue				# If so, ignore line, check next line, still add line number though
					fi
					char_escape nm_list_line_raw
					for nm_list_word in $nm_list_line_raw; do				# Validate each word in line
						if [[ $nm_list_word == \#* || $nm_list_word == '#' ]]; then	# Ignore comments
							# If word starts with '#', stop reading (probably is a comment)
							break
						fi
						if (( fl_nm_list_ug == 0 )); then
							users[$fl_nm_list_c]=$nm_list_word
							((nm_list_user_no++))
						else
							groups[$fl_nm_list_c]=$nm_list_word
							((nm_list_group_no++))
						fi
						((fl_nm_list_c++))
					done
					((nm_list_file_line_no++))
					((nm_list_file_a_line_no++))
				done < "$(char_deescape_echo file_name_stitch_string)"
				((nm_list_file_no++))
			else					# If it's the last '<END', then do standard syntax checking for '<END'
				if (( ${#line[@]} > 1 )); then
					echo "$line_no : Too many operands after <END"
					c_error=1
					break
				fi
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				fl_start_type=0
				fl_w_list=0
				fl_w_list_type=0
				fl_nm_list_c=0
				fl_nm_list_specified=0
				((nm_list_no++))
			fi
		fi
	fi
    if (( $c_error == 1)); then break; fi
	((line_no++))
    ((a_line_no++))
	unset line
done < "$filelist"
fl_l=0
#echo "USERS"
#for ((i=0; i < ${#users[@]}; i++)); do
#	echo "${users[$i]}"
#done
#for ((i=0; i < ${#groups[@]}; i++)); do
#	echo "${groups[$i]}"
#done
if (( $c_error == 1 )); then
	exit
fi
if (( $fl_o != 0 )); then
	echo "$line_no : Incomplete entry"
	exit
fi
if (( $fl_I_d == 1 )); then
	if (( $fl_I_g == 0 )); then
		echo ""
	fi
	echo "# Time            : $(date +%H\:%M\ %d/%m/%Y)"
fi
if (( $fl_I_s == 1 )); then
	if (( $fl_I_g == 1 )); then
		echo "#"
	else
		echo ""
	fi
	echo "# Statistics"
	echo "#"
	echo "# General:"
	echo "# Lines in file                  : $[$line_no-1]"
	echo "# Lines of rules                 : $[$a_line_no-1]"
	echo "# Warnings                       : $c_warn"
	echo "#"
	echo "# name list:"
	echo "# Blocks                         : $nm_list_no"
	echo "# Files                          : $nm_list_file_no"
	echo "# File lines read                : $nm_list_file_line_no"
	echo "# File lines processed           : $nm_list_file_a_line_no"
	echo "# Users                          : $nm_list_user_no"
	echo "# Groups                         : $nm_list_group_no"
	echo "#"
	echo "# setfacl:"
	echo "# ACL blocks                     : $acl_block_no"
	echo "# STRAY entries                  : $stray_no"
	echo "# Number of files or directories : $file_no"
	echo "#"
	echo "# chown:"
	echo "# Blocks                         : $chown_no"
	echo "# Number of files or directories : $chown_file_no"
	echo "#"
	echo "# chmod:"
	echo "# Blocks                         : $chmod_no"
	echo "# Number of files or directories : $chmod_file_no"
	echo "#"
	echo "# chattr:"
	echo "# Blocks                         : $chattr_no"
	echo "# Number of files or directories : $chattr_file_no"
	echo "#"
	echo "# append:"
	echo "# Blocks                         : $append_no"
	echo "# Lines of text                  : $append_text_no"
	echo "# Number of files                : $append_file_no"
	echo "#"
	echo "# insert:"
	echo "# Blocks                         : $insert_no"
	echo "# Lines of text                  : $insert_text_no"
	echo "# Number of files                : $insert_file_no"
	echo "#"
	echo "# replace:"
	echo "# Blocks                         : $replace_no"
	echo "# Lines of Old text              : $replace_old_text_no"
	echo "# Lines of New text              : $replace_new_text_no"
	echo "# Number of files                : $replace_file_no"
	echo "#"
	echo "# command:"
	echo "# Blocks                         : $cmd_no"
	echo "# Lines                          : $cmd_line_no"
fi
if (( $fl_I_t == 1 )); then
	echo "No error detected"
	exit
fi
for (( i=0; i < ${#users[@]}; i++ )); do
	fl_u[$i]=0
done
for (( i=0; i < ${#groups[@]}; i++ )); do
	fl_g[$i]=0
done
fl_i=1
fl_insert_index=0
fl_replace_index=0
line_no=1
while read -r line_raw; do
	if [[ ($line_raw =~ ^$  || -z $line_raw || $line_raw =~ ^# ) ]]; then	# Check if line is empty/null/spaces or starts with '#'
		((line_no++))
		continue				# If so, ignore line, check next line, still add line number though
	fi
	for (( i=0; i < ${#users[@]}; i++ )); do	# Initialise 'users' array
		fl_u_valid_line[$i]=0
		fl_u_checked[$i]=0
	done
	for (( i=0; i < ${#groups[@]}; i++ )); do	# Initialise 'groups' array
		fl_g_valid_line[$i]=0
		fl_g_checked[$i]=0
	done
	char_escape_quiet line_raw
	i=0
	line=()						# Initialise primary line buffer
	for word in $line_raw; do				# Validate each word in line
		if [[ $word == \#* || $word == '#' ]]; then	# Ignore comments
			# If word starts with '#', stop reading (probably is a comment)
			break
		fi
		line[$i]="$word"                              # Push words to line[]
		((i++))
	done
	if (( $fl_f_list == 0 )); then
		case  ${line[0]} in
		"@NAME_LIST"	)
					fl_o=0
					fl_start_type=4
					fl_nm_list_specified=1
				;;
		"@STRAY" )	
				for (( i=1; i < ${#line[@]}; i++ )); do
					case ${line[$i]} in
						"NO" )	fl_no=1
							;;
						RES )	
							;;
						USR )	
							;;
						GRP )	
							;;
						P )	fl_P=1
							;;
						D )	fl_D=1
							;;
						R )	fl_R=1
							;;
						* )	if [[ ${line[$i-1]} == "USR" ]]; then
								for (( j=0; j < ${#users[@]}; j++ )); do
									if [[ ${line[$i]} == ${users[$j]} ]]; then
										fl_u[$j]=1
										break
									fi
								done
							fi
							if [[ ${line[$i-1]} == "GRP" ]]; then
								for (( j=0; j < ${#groups[@]}; j++ )); do
									if [[ ${line[$i]} == ${groups[$j]} ]]; then
										fl_g[$j]=1
										break
									fi
								done
							fi
							if [[ ${line[$i-1]} == "P" ]]; then
								fl_stray_P_str=$i
							fi
							if [[ ${line[$i-1]} == "D" ]]; then
								fl_stray_D_str=$i
							fi
							;;
					esac
				done
				if (( $fl_no == 1 )); then
					perm_set users[@] groups[@] fl_u[@] fl_g[@] fl_no s_aperm line[$[${#line[@]}-1]] temp fl_R fl_NOALL fl_apply fl_gen
				fi
				if (( $fl_P == 1 )) && (( $fl_no == 0 )); then
					temp=0
					s_aperm=${line[$fl_stray_P_str]}
					perm_set users[@] groups[@] fl_u[@] fl_g[@] fl_no s_aperm line[$[${#line[@]}-1]] temp fl_R fl_NOALL fl_apply fl_gen
				fi
				if (( $fl_D == 1 )) && (( $fl_no == 0 )); then
					s_aperm=${line[$fl_stray_D_str]}
					perm_set users[@] groups[@] fl_u[@] fl_g[@] fl_no s_aperm line[$[${#line[@]}-1]] fl_D fl_R fl_NOALL fl_apply fl_gen
				fi
				fl_P=0
				fl_D=0
				fl_R=0
				fl_no=0
				for (( i=0; i < ${#users[@]}; i++ )); do
					fl_u[$i]=0
				done
				for (( i=0; i < ${#groups[@]}; i++ )); do
					fl_g[$i]=0
				done
			;;
		"@CHOWN" )
				fl_o=0
				for (( i=1; i < ${#line[@]}; i++ )); do
					case ${line[$i]} in
					USER )	fl_o=1
							fl_chown_u_specified=1
						;;
					GROUP )	fl_o=1
							fl_chown_g_specified=1
						;;
					RECUR )	fl_o=1
							fl_chown_recur=1
						;;
					* )		if [[ ${line[$i-1]} == "USER" ]]; then
								fl_chown_u=${line[$i]}
							fi
							if [[ ${line[$i-1]} == "GROUP" ]]; then
								fl_chown_g=${line[$i]}
							fi
						;;
					esac
				done
				fl_f_list=1
				fl_f_list_type=1
				end_line_no=$(check_end)
			;;
		"@CHMOD" )	fl_o=0
				chmod_perm_string=${line[1]}
				if (( ${#line[@]} == 3 )); then
					if [[ ${line[2]} == "RECUR" ]]; then
						fl_chmod_recur=1
					fi
				fi
				fl_f_list=1
				fl_f_list_type=2
				end_line_no=$(check_end)
			;;
		"@CHATTR" )fl_o=0
				for (( i=1; i < $[${#line[@]}-1]; i++ )); do
					case ${line[$i]} in
					RECUR )		fl_chattr_recur=1
						;;
					VERBOSE )	fl_chattr_verbose=1
						;;
					VERSION )	fl_chattr_version=1
						;;
					* )			if [[ ${line[$i-1]} == "VERSION" ]]; then
									chattr_version_no=${line[$i]}
								fi
						;;
					esac
				done
				chattr_string=${line[$[${#line[@]}-1]]}
				if (( ($fl_chattr_recur + $fl_chattr_verbose + $fl_chattr_version) != 0 )); then
					chattr_arg_string+="-"
				fi
				if (( $fl_chattr_recur == 1 )); then
					chattr_arg_string+="R"
				fi
				if (( $fl_chattr_verbose == 1 )); then
					chattr_arg_string+="V"
				fi
				if (( ($fl_chattr_recur + $fl_chattr_verbose) != 0 )); then
					chattr_arg_string+=' '
				fi
				if (( $fl_chattr_version == 1 )); then
					chattr_arg_string+="-v $chattr_version_no "
				fi
				fl_f_list=1
				fl_f_list_type=3
				end_line_no=$(check_end)
			;;
		"@APPEND" )	fl_o=0
					fl_append_specified=1
					fl_start_type=1
					fl_w_list_type=0
			;;
		"@INSERT" )	fl_o=0
					fl_insert_specified=1
					fl_start_type=2
					fl_w_list_type=1
					fl_insert_line=0
					fl_insert_after=0
					((fl_insert_index++))
					insert_string_buffer_after=""
					insert_string_buffer=""
					sed_mul_line_string=""
					fl_insert_string_after_first=1
					fl_insert_string_first=1
					after_line_no=$(check_after)
			;;
		"@REPLACE" )	fl_o=0
					fl_replace_specified=1
					fl_start_type=3
					fl_w_list_type=2
					fl_replace_with=0
					((fl_replace_index++))
					replace_string_buffer_with=""
					replace_string_buffer=""
					sed_mul_line_string=""
					fl_replace_string_with_first=1
					fl_replace_string_first=1
					with_line_no=$(check_with)
			;;
		"@COMMAND" )	fl=0
					fl_w_list_type=3
					fl_start_type=4
					end_line_no=$(check_end)
			;;
		"!NO" )	fl_no=1		# action by default is 'm', if !NO is specified, action changes to 'x'
				if (( ${#line[@]} == 2 )); then
					fl_NOALL=1
				fi
			;;
		"@RESTRICT" )	case ${line[1]} in
						USER )	if [[ ${line[2]} == "ALL" ]]; then		# If ALL is specified, mark all users
									for (( j=0; j < ${#users[@]}; j++ )); do
										fl_u[$j]=1	# Set 1 to mark user will be selected
									done
								else						# If not, then mark individual users
									for (( i=2; i < ${#line[@]}; i++ )); do
										for (( j=0; j < ${#users[@]}; j++ )); do
											if [[ ${line[$i]} == ${users[$j]} ]] && !(( ${fl_u[$j]} == 1 )); then
												fl_u[$j]=1	# Set 1 to mark user will be selected
											fi
										done
									done
								fi
							;;
						GROUP ) if [[ ${line[2]} == "ALL" ]]; then		# If ALL is specified, mark all groups
								for (( j=0; j < ${#groups[@]}; j++ )); do
									fl_g[$j]=1	# Set 1 to mark user will be selected
								done
							else						# If not, then mark individual groups
								for (( i=2; i < ${#line[@]}; i++ )); do
									for (( j=0; j < ${#groups[@]}; j++ )); do
										if [[ ${line[$i]} == ${groups[$j]} ]] && !(( ${fl_g[$j]} == 1 )); then
											fl_g[$j]=1	# Set 1 to mark user will be selected
										fi
									done
								done
							fi
							;;
						esac
						fl_start_type=0
			;;
		"@EXCLUDE" )	case ${line[1]} in
					USER )	for (( i=2; i < ${#line[@]}; i++ )); do		# Mark individual users
								for (( j=0; j < ${#users[@]}; j++ )); do
									if [[ ${line[$i]} == ${users[$j]} ]] && !(( ${fl_u[$j]} == 0 )); then
										fl_u[$j]=0	# Set 0 to mark user will not be selected
									fi
								done
							done
						;;
					GROUP ) for (( i=2; i < ${#line[@]}; i++ )); do		# Mark individual groups
								for (( j=0; j < ${#groups[@]}; j++ )); do
									if [[ ${line[$i]} == ${groups[$j]} ]] && !(( ${fl_g[$j]} == 0 )); then
										fl_g[$j]=0	# Set 0 to mark group will not be selected
									fi
								done
							done
						;;
					esac
			;;
		"+PERM" )		d_perm=${line[1]}	# Default permission of current ACL block, can be number or string
					fl_perm=1
			;;
		"+DPERM" )		d_dperm=${line[1]}
					fl_dperm=1
			;;
		"+RECUR" )		fl_R=1
			;;
		">START" )  if (( $fl_start_type == 0 )); then
						fl_o=3
						fl_f_list=1
						end_line_no=$(check_end)
					fi
					if (( $fl_start_type == 1 )); then
						fl_f_list=1
						fl_f_list_type=4
						end_line_no=$(check_end)
					fi
					if (( $fl_start_type == 2 )); then
						fl_f_list=1
						fl_f_list_type=5
						end_line_no=$(check_end)
					fi
					if (( $fl_start_type == 3 )); then
						fl_f_list=1
						fl_f_list_type=6
						end_line_no=$(check_end)
					fi
					if (( $fl_start_type == 4 )); then
						if (( $fl_nm_list_ft == 0 )); then
							fl_f_list=1
							fl_f_list_type=7
						else
							fl_nm_list_c=0
							fl_w_list_type=4
						fi
						end_line_no=$(check_end)
					fi
			;;
		* )			if (( $fl_w_list_type == 0 )); then
						if (( $fl_append_string_first == 1 )); then
							append_string_buffer+="$line_raw"
							fl_append_string_first=0
						else
							append_string_buffer+="\n$line_raw"
						fi
					fi
					if (( $fl_w_list_type == 1 )); then
						if (( $line_no != $after_line_no )); then
							case ${line[0]} in
							"@LINE" )	fl_insert_line=1
										insert_line_or_after[$fl_insert_index]=1
										insert_line_number_array[$fl_insert_index]=${line[1]}
								;;
							* )		if (( $fl_insert_after == 1 )); then
										if (( $fl_insert_string_after_first == 1 )); then
											insert_string_buffer_after+="$line_raw"
											insert_string_buffer_after_array[$fl_insert_index]=$insert_string_buffer_after
											fl_insert_string_after_first=0
										else
											insert_string_buffer_after+="\n$line_raw"
											insert_string_buffer_after_array[$fl_insert_index]=$insert_string_buffer_after
											sed_mul_line_string+="N;"
											insert_sed_mul_line_string_array[$fl_insert_index]=$sed_mul_line_string
										fi
									else
										if (( $fl_insert_string_first == 1 )); then
											insert_string_buffer+="$line_raw"
											insert_string_buffer_array[$fl_insert_index]=$insert_string_buffer
											fl_insert_string_first=0
										else
											insert_string_buffer+="\n$line_raw"
											insert_string_buffer_array[$fl_insert_index]=$insert_string_buffer
										fi
									fi
								;;
							esac
						else
							fl_insert_after=1
							insert_line_or_after[$fl_insert_index]=0
						fi
					fi
					if (( $fl_w_list_type == 2 )); then
						if (( $line_no != $with_line_no )); then
							if (( $fl_replace_with == 1 )); then
								if (( $fl_replace_string_with_first == 1 )); then
									replace_string_buffer_with+="$line_raw"
									replace_string_buffer_with_array[$fl_replace_index]=$replace_string_buffer_with
									fl_replace_string_with_first=0
								else
									replace_string_buffer_with+="\n$line_raw"
									replace_string_buffer_with_array[$fl_replace_index]=$replace_string_buffer_with
									replace_sed_mul_line_string_array[$fl_replace_index]=$sed_mul_line_string
								fi
							else
								if (( $fl_replace_string_first == 1 )); then
									replace_string_buffer+="$line_raw"
									replace_string_buffer_array[$fl_replace_index]=$replace_string_buffer
									fl_replace_string_first=0
								else
									replace_string_buffer+="\n$line_raw"
									replace_string_buffer_array[$fl_replace_index]=$replace_string_buffer
									replace_sed_mul_line_string_array[$fl_replace_index]=$sed_mul_line_string
									replace_mul_line=1
								fi
							fi
						else
							if (( $fl_replace_with == 1 )); then
								if (( $fl_replace_string_with_first == 1 )); then
									replace_string_buffer_with+="$line_raw"
									replace_string_buffer_with_array[$fl_replace_index]=$replace_string_buffer_with
									fl_replace_string_with_first=0
								else
									replace_string_buffer_with+="\n$line_raw"
									replace_string_buffer_with_array[$fl_replace_index]=$replace_string_buffer_after
									replace_sed_mul_line_string_array[$fl_replace_index]=$sed_mul_line_string
								fi
							else
								fl_replace_with=1
							fi
						fi
					fi
					if (( $fl_w_list_type == 3 )); then
						if (( $line_no != $end_line_no )); then
							if (( $fl_I_a == 1 )); then
								echo "$(char_deescape_echo line_raw)"
							fi
							if (( $fl_I_g == 1 )); then
								echo "$(char_deescape_echo line_raw)"
							fi
						else
							fl_o=0
							fl_f_list=0
							fl_f_list_type=0
							fl_start_type=0
							fl_w_list=0
							fl_w_list_type=0
						fi
					fi
					if (( $fl_w_list_type == 4 )); then
						if (( $line_no != $end_line_no)); then
							if (( fl_nm_list_ug == 0 )); then
								for ((j=0; j<${#line[@]}; j++)); do
									users[$fl_nm_list_c]=${line[$j]}
									((nm_list_user_no++))
									((fl_nm_list_c++))
								done
							else
								for ((j=0; j<${#line[@]}; j++)); do
									groups[$fl_nm_list_c]=${line[$j]}
									((nm_list_group_no++))
									((fl_nm_list_c++))
								done
							fi
						else
							fl_o=0
							fl_f_list=0
							fl_f_list_type=0
							fl_start_type=0
							fl_w_list=0
							fl_w_list_type=0
							fl_nm_list_c=0
							fl_nm_list_specified=0
							((nm_list_no++))
							for (( i=0; i < ${#users[@]}; i++ )); do
								fl_u[$i]=0
							done
							for (( i=0; i < ${#groups[@]}; i++ )); do
								fl_g[$i]=0
							done
						fi
					fi
			;;
		esac
	else
		if (( $fl_f_list_type == 0 )); then
			if [[ $line_no != $end_line_no ]]; then
				filename_stitch_quiet line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $[${#line[@]}-$file_name_stitch_c+1] == 1 )); then		# No individual permission specified, follow default permission
					if (( $fl_no == 1 )); then
						perm_set users[@] groups[@] fl_u[@] fl_g[@] fl_no a_perm file_name_stitch_string fl_D fl_R fl_NOALL fl_apply fl_gen
					fi
					if (( $fl_perm == 1 )) && (( $fl_no == 0 )); then
						fl_D=0
						perm_set users[@] groups[@] fl_u[@] fl_g[@] fl_no d_perm file_name_stitch_string fl_D fl_R fl_NOALL fl_apply fl_gen
					fi
					if (( $fl_dperm == 1 )) && (( $fl_no == 0 )); then
						fl_D=1
						perm_set users[@] groups[@] fl_u[@] fl_g[@] fl_no d_dperm file_name_stitch_string fl_D fl_R fl_NOALL fl_apply fl_gen
					fi
					fl_D=0
				else	if (( $[${#line[@]}-$file_name_stitch_c+1] == 3 )); then
							for (( i=0; i < ${#line[$[$file_name_stitch_c+1]]}; i++ )); do
								case ${line[$[$file_name_stitch_c+1]]:$i:1} in
									P )	fl_P=1
										;;
									D )	fl_D=1
										;;
									R )	fl_R=1
										;;
								esac
							done
							if (( $fl_P == 1 )); then
								a_perm=${line[$file_name_stitch_c]}
								perm_set users[@] groups[@] fl_u[@] fl_g[@] fl_no a_perm file_name_stitch_string fl_D fl_R fl_NOALL fl_apply fl_gen
							fi
							if (( $fl_D == 1 )); then
								a_dperm=${line[$file_name_stitch_c]}
								perm_set users[@] groups[@] fl_u[@] fl_g[@] fl_no a_dperm file_name_stitch_string fl_D fl_R fl_NOALL fl_apply fl_gen
							fi
						else	# ${#line[@]} == 4
							a_perm=${line[$file_name_stitch_c]}
							a_dperm=${line[$file_name_stitch_c]}
							for (( i=0; i < ${#line[$[$file_name_stitch_c+2]]}; i++ )); do
								if [[ ${line[3]:$i:1} == 'R' ]]; then
									fl_R=1
									break
								fi
							done
							perm_set users[@] groups[@] fl_u[@] fl_g[@] fl_no a_perm file_name_stitch_string fl_D fl_R fl_NOALL fl_apply fl_gen
							fl_D=1
							perm_set users[@] groups[@] fl_u[@] fl_g[@] fl_no a_dperm file_name_stitch_string fl_D fl_R fl_NOALL fl_apply fl_gen
							fl_D=0
						fi
				fi
				fl_P=0
				fl_D=0
				fl_R=0
			else
				for (( i=0; i < ${#users[@]}; i++ )); do
					fl_u[$i]=0
				done
				for (( i=0; i < ${#groups[@]}; i++ )); do
					fl_g[$i]=0
				done
				unset d_perm
				# Reset flags
				# The following flags are used for the whole block
				fl_no_b=$fl_no
				fl_no=0
				fl_NOALL=0
				fl_f_list=0
				fl_e=1
				fl_recur=0
			fi
		fi
		if (( $fl_f_list_type == 1 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				filename_stitch_quiet line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $fl_I_a == 1 )); then
					if (( $fl_chown_u_specified == 0 )); then
						if (( $fl_chown_recur == 0 )); then
							chown :$fl_chown_g "$(char_deescape_echo file_name_stitch_string)"
						else
							chown -R :$fl_chown_g "$(char_deescape_echo file_name_stitch_string)"
						fi
					else
						if (( $fl_chown_g_specified == 0 )); then
							if (( $fl_chown_recur == 0 )); then
								chown $fl_chown_u "$(char_deescape_echo file_name_stitch_string)"
							else
								chown -R $fl_chown_u "$(char_deescape_echo file_name_stitch_string)"
							fi
						else
							if (( $fl_chown_recur == 0 )); then
								chown $fl_chown_u:$fl_chown_g "$(char_deescape_echo file_name_stitch_string)"
							else
								chown -R $fl_chown_u:$fl_chown_g "$(char_deescape_echo file_name_stitch_string)"
							fi
						fi
					fi
				fi
				if (( $fl_I_g == 1 )); then
					if (( $fl_chown_u_specified == 0 )); then
						if (( $fl_chown_recur == 0 )); then
							echo "chown :$fl_chown_g $(char_deescape_echo file_name_stitch_string)"
						else
							echo "chown -R :$fl_chown_g $(char_deescape_echo file_name_stitch_string)"
						fi
					else
						if (( $fl_chown_g_specified == 0 )); then
							if (( $fl_chown_recur == 0 )); then
								echo "chown $fl_chown_u $(char_deescape_echo file_name_stitch_string)"
							else
								echo "chown -R $fl_chown_u $(char_deescape_echo file_name_stitch_string)"
							fi
						else
							if (( $fl_chown_recur == 0 )); then
								echo "chown $fl_chown_u:$fl_chown_g $(char_deescape_echo file_name_stitch_string)"
							else
								echo "chown -R $fl_chown_u:$fl_chown_g $(char_deescape_echo file_name_stitch_string)"
							fi
						fi
					fi
				fi
			else					# If it's the last '<END', then do standard syntax checking for '<END'
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				fl_chown_recur=0
			fi
		fi
		if (( $fl_f_list_type == 2 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				filename_stitch_quiet line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $fl_I_a == 1 )); then
					if (( $fl_chmod_recur == 0 )); then
						chmod $chmod_perm_string "$(char_deescape_echo file_name_stitch_string)"
					else
						chmod -R $chmod_perm_string "$(char_deescape_echo file_name_stitch_string)"
					fi
				fi
				if (( $fl_I_g == 1 )); then
					if (( $fl_chmod_recur == 0 )); then
						echo "chmod $chmod_perm_string $(char_deescape_echo file_name_stitch_string)"
					else
						echo "chmod -R $chmod_perm_string $(char_deescape_echo file_name_stitch_string)"
					fi
				fi
			else					# If it's the last '<END', then do standard syntax checking for '<END'
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				fl_chmod_recur=0
			fi
		fi
		if (( $fl_f_list_type == 3 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				filename_stitch_quiet line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $fl_I_a == 1 )); then
					chattr $chattr_arg_string$chattr_string "$(char_deescape_echo file_name_stitch_string)"
				fi
				if (( $fl_I_g == 1 )); then
					echo "chattr $chattr_arg_string$chattr_string $(char_deescape_echo file_name_stitch_string)"
				fi
			else					# If it's the last '<END', then do standard syntax checking for '<END'
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				fl_chattr_recur=0
				fl_chattr_verbose=0
				fl_chattr_version=0
				fl_chattr_version_c=0
				chattr_version_no=0
				chattr_no=0
				chattr_file_no=0
				chattr_string=""
				chattr_arg_string=""
			fi
		fi
		if (( $fl_f_list_type == 4 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				filename_stitch_quiet line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $fl_I_a == 1 )); then
					append_string_buffer="$(char_deescape_echo append_string_buffer)"
					echo -e "$append_string_buffer" >> "$(char_deescape_echo file_name_stitch_string)"
				fi
				if (( $fl_I_g == 1 )); then
					append_string_buffer="$(char_deescape_echo append_string_buffer)"
					echo "echo -e \"$append_string_buffer\" >> $(char_deescape_echo file_name_stitch_string)"
				fi
			else
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				fl_start_type=0
				fl_w_list=0
				fl_w_list_type=0
				fl_append_specified=0
				fl_append_string_first=1
				append_string_buffer=""
			fi
		fi
		if (( $fl_f_list_type == 5 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				filename_stitch_quiet line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $fl_I_a == 1 )); then
					for ((i=1; i <= $fl_insert_index; i++)); do
						sed_mul_line_string=${insert_sed_mul_line_string_array[$i]}
						insert_string_buffer_after="$(char_deescape_echo insert_string_buffer_after_array[$i])"
						insert_string_buffer_after="$(echo $insert_string_buffer_after | sed 's,/,\\\/,g')"
						insert_string_buffer="$(char_deescape_echo insert_string_buffer_array[$i])"
						insert_string_buffer="$(echo $insert_string_buffer | sed 's,/,\\\/,g')"
						insert_line_number="${insert_line_number_array[$i]}"
						if (( ${insert_line_or_after[$i]} == 0 )); then
							if ! ls $(char_deescape_echo file_name_stitch_string) &> /dev/null; then
								if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) ))&& (( $fl_gen == 0 )); then
									echo "Warning : $line_no : @INSERT : ""$(char_deescape_echo file_name_stitch_string)"" does not exist, file ignored"
								fi
								break
							fi
							insert_filename_string="$(ls -1 $(char_deescape_echo file_name_stitch_string) | sed ':a;N;$!ba;s/ />/g' |  sed ':a;N;$!ba;s/\n/ /g' )"
							for temp6 in $insert_filename_string; do
								temp6=$(echo $temp6 | sed 's/>/ /g')
								insert_line_number="$(cat $temp6 | sed -n "$sed_mul_line_string/$insert_string_buffer_after/=" | sed ':a;N;$!ba;s/\n/ /g')"
								insert_line_number_array=()
								j=0
								temp5=0
								for temp4 in $insert_line_number; do
									insert_line_number_array[$j]=$temp4
									((j++))
								done
								for (( j=0; j < ${#insert_line_number_array[@]}; j++ )); do
									if (( $j == $[${#insert_line_number_array[@]}-1] )) && (( $(cat $temp6 | wc -l) == ${insert_line_number_array[$[${#insert_line_number_array[@]}-1]]} )); then
										echo -ne "$insert_string_buffer" >> "$temp6"
									else
										IFS= temp3="$(cat $temp6 | sed "$[${insert_line_number_array[$j]}+1+$temp5] i $insert_string_buffer")"
										((temp5++))
										echo -n "$temp3" > "$temp6"
									fi
								done
							done
						else
							if ! ls $(char_deescape_echo file_name_stitch_string) &> /dev/null; then
								if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) ))&& (( $fl_gen == 0 )); then
									echo "Warning : $line_no : @INSERT : ""$(char_deescape_echo file_name_stitch_string)"" does not exist, file ignored"
								fi
								break
							fi
							insert_filename_string="$(ls -1 $(char_deescape_echo file_name_stitch_string) | sed ':a;N;$!ba;s/ />/g' |  sed ':a;N;$!ba;s/\n/ /g' )"
							for temp4 in $insert_filename_string; do
								temp4=$(echo "$temp4" | sed 's/>/ /g')
								if (( $(cat "$temp4" | wc -l) < $insert_line_number )); then
									echo -ne "$insert_string_buffer" >> "$temp4"
								else
									IFS= temp3="$(cat $temp4 | sed "$insert_line_number i $insert_string_buffer")"
									echo -n "$temp3" > "$temp4"
								fi
							done
						fi
					done
				fi
				if (( $fl_I_g == 1 )); then
					for ((i=1; i <= $fl_insert_index; i++)); do
						sed_mul_line_string="${insert_sed_mul_line_string_array[$i]}"
						insert_string_buffer_after="$(char_deescape_echo insert_string_buffer_after_array[$i])"
						insert_string_buffer_after="$(echo $insert_string_buffer_after | sed 's,/,\\\/,g')"
						insert_string_buffer="$(char_deescape_echo insert_string_buffer_array[$i])"
						insert_string_buffer="$(echo $insert_string_buffer | sed 's,/,\\\/,g')"
						insert_line_number="${insert_line_number_array[$i]}"
						if (( ${insert_line_or_after[$i]} == 0 )); then
							echo "if ! ls $(char_deescape_echo file_name_stitch_string) &> /dev/null; then"
							if (( $gen_script_w == 1 )); then
								echo "    echo \"Warning : $line_no : @INSERT : ""$(char_deescape_echo file_name_stitch_string)"" does not exist, file ignored\""
							fi
                     echo "    :"
							echo "else"
							echo "    insert_filename_string=\"\$(ls -1 $(char_deescape_echo file_name_stitch_string) | sed ':a;N;$!ba;s/ />/g' |  sed ':a;N;$!ba;s/\n/ /g' )\""
							echo "    for temp4 in \$insert_filename_string; do"
							echo "    temp4=\$(echo \$temp4 | sed 's/>/ /g')"
							echo "        insert_line_number=\"\$(cat \$temp4 | sed -n \"$sed_mul_line_string/$insert_string_buffer_after/=\" | sed ':a;N;$!ba;s/\n//g')\""
							echo "        insert_line_number_array=()"
							echo "        j=0"
							echo "        temp3=0"
							echo "        for temp2 in \$insert_line_number; do"
							echo "            insert_line_number_array[\$j]=\$temp2"
							echo "            ((j++))"
							echo "        done"
							echo "        for (( j=0; j < \${#insert_line_number_array[@]}; j++ )); do"
							echo "            if (( \$j == \$[\${#insert_line_number_array[@]}-1] )) && (( \$(cat \$temp4 | wc -l) == \${insert_line_number_array[\$[\${#insert_line_number_array[@]}-1]]} )); then"
							echo "                echo -ne \"$insert_string_buffer\" >> \"\$temp4\""
							echo "            else"
							echo "                IFS= temp=\"\$(cat \$temp4 | sed \"\$[\${insert_line_number_array[\$j]}+1+\$temp3] i $insert_string_buffer\")\""
							echo "                ((temp3++))"
							echo "                echo -n \"\$temp\" > \"\$temp4\""
							echo "            fi"
							echo "        done"
							echo "    done"
                     echo "fi"
						else
							echo "if ! ls $(char_deescape_echo file_name_stitch_string) &> /dev/null; then"
							if (( $gen_script_w == 1 )); then
								echo "    echo \"Warning : $line_no : @INSERT : ""$(char_deescape_echo file_name_stitch_string)"" does not exist, file ignored\""
							fi
							echo "    :"
							echo "else"
							echo "    insert_filename_string=\"\$(ls -1 $(char_deescape_echo file_name_stitch_string) | sed ':a;N;$!ba;s/ />/g' |  sed ':a;N;$!ba;s/\n/ /g' )\""
							echo "    for temp2 in \$insert_filename_string; do"
							echo "        temp2=\$(echo \"\$temp2\" | sed 's/>/ /g')"
							echo "        if (( \$(cat \"\$temp2\" | wc -l) < $insert_line_number )); then"
							echo "            echo -ne \"$insert_string_buffer\" >> \"\$temp2\""
							echo "        else"
							echo "            IFS= temp=\"\$(cat \"\$temp2\" | sed \"$insert_line_number i $insert_string_buffer\")\""
							echo "            echo -n \"\$temp\" > \"\$temp2\""
							echo "        fi"
							echo "    done"
                     echo "fi"
						fi
					done
				fi
			else
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				fl_start_type=0
				fl_w_list=0
				fl_w_list_type=0
				fl_insert_specified=0
				fl_insert_line=0
				fl_insert_after=0
				fl_insert_string_first=1
				fl_insert_string_after_first=1
				insert_string_buffer=""
				insert_string_buffer_after=""
				fl_insert_index=0
			fi
		fi
		if (( $fl_f_list_type == 6 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				filename_stitch_quiet line[@] file_name_stitch_string file_name_stitch_c c_error
				if (( $fl_I_a == 1 )); then
					for ((i=1; i <= $fl_replace_index; i++ )); do
						sed_mul_line_string=${replace_sed_mul_line_string_array[$i]}
						replace_string_buffer_with="$(char_deescape_echo replace_string_buffer_with_array[$i])"
						replace_string_buffer_with="$(echo $replace_string_buffer_with | sed 's,/,\\\/,g')"
						replace_string_buffer="$(char_deescape_echo replace_string_buffer_array[$i])"
						replace_string_buffer="$(echo $replace_string_buffer | sed 's,/,\\\/,g')"
						if ! ls $(char_deescape_echo file_name_stitch_string) &> /dev/null; then
							if (( $char_escape_warn_w == 1 )) && (( (( $fl_apply == 1 )) || (( $fl_I_t == 1 )) ))&& (( $fl_gen == 0 )); then
								echo "Warning : $line_no : @REPLACE : ""$(char_deescape_echo file_name_stitch_string)"" does not exist, file ignored"
							fi
							break
						fi
						replace_filename_string="$(ls -1 $(char_deescape_echo file_name_stitch_string) | sed ':a;N;$!ba;s/ />/g' |  sed ':a;N;$!ba;s/\n/ /g' )"
						for temp4 in $replace_filename_string; do
							temp4=$(echo $temp4 | sed 's/>/ /g')
							if (( $replace_mul_line == 1 )); then
								IFS= temp3="$(cat $temp4 | sed ':a;N;$!ba;'"s/$replace_string_buffer/$replace_string_buffer_with/g")"
								echo -n "$temp3" > "$temp4"
							else
								IFS= temp3="$(cat $temp4 | sed "s/$replace_string_buffer/$replace_string_buffer_with/g")"
								echo -n "$temp3" > "$temp4"
							fi
						done
					done
				fi
				if (( $fl_I_g == 1 )); then
					for ((i=1; i <= $fl_replace_index; i++ )); do
						sed_mul_line_string=${replace_sed_mul_line_string_array[$i]}
						replace_string_buffer_with="$(char_deescape_echo replace_string_buffer_with_array[$i])"
						replace_string_buffer_with="$(echo $replace_string_buffer_with | sed 's,/,\\\/,g')"
						replace_string_buffer="$(char_deescape_echo replace_string_buffer_array[$i])"
						replace_string_buffer="$(echo $replace_string_buffer | sed 's,/,\\\/,g')"
						echo "if ! ls $(char_deescape_echo file_name_stitch_string) &> /dev/null; then"
						if (( $gen_script_w == 1 )); then
							echo "    echo \"Warning : $line_no : @REPLACE : ""$(char_deescape_echo file_name_stitch_string)"" does not exist, file ignored\""
						fi
						echo "    :"
						echo "else"
						echo "    replace_filename_string=\"\$(ls -1 $(char_deescape_echo file_name_stitch_string) | sed ':a;N;$!ba;s/ />/g' |  sed ':a;N;$!ba;s/\n/ /g' )\""
						echo "    for temp2 in \$replace_filename_string; do"
						echo "        temp2=\$(echo \$temp2 | sed 's/>/ /g')"
						if (( $replace_mul_line == 1 )); then
							echo "        IFS= temp=\"\$(cat \$temp2 | sed ':a;N;\$!ba;'\"s/$replace_string_buffer/$replace_string_buffer_with/g\")\""
							echo "        echo \"\$temp\" > \"\$temp2\""
						else
							echo "        IFS= temp=\"\$(cat \$temp2 | sed \"s/$replace_string_buffer/$replace_string_buffer_with/g\")\""
							echo "        echo \"\$temp\" > \"\$temp2\""
						fi
						echo "    done"
                  echo "fi"
					done
				fi
			else
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				fl_start_type=0
				fl_w_list=0
				fl_w_list_type=0
				fl_replace_specified=0
				fl_replace_string_first=1
				replace_string_buffer=""
				fl_replace_with=0
				replace_string_buffer_with=""
				fl_replace_string_with_first=1
				fl_replace_index=0
				replace_mul_line=0
			fi
		fi
		if (( $fl_f_list_type == 7 )); then
			if [[ $line_no != $end_line_no ]]; then	# If it's not the last '<END', process it as file name
				((nm_list_file_no++))
			else
				fl_o=0
				fl_f_list=0
				fl_f_list_type=0
				fl_start_type=0
				fl_w_list=0
				fl_w_list_type=0
				fl_nm_list_c=0
				fl_nm_list_specified=0
				((nm_list_no++))
			fi
		fi
	fi
	((line_no++))
	unset line
done < "$filelist"
