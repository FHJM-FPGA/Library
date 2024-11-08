//				if(char [char_index [4]] [ (CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos)*CHAR_WIDTH - ((pixel_xpos-CHAR_POS_X)%CHAR_WIDTH) -1 ]  )
//			   // 字符       哪个字符            字符高度    起始点纵坐标   y像素点     字符宽度        x像素点     起始点横坐标  字符宽度
//				gui_data <= WHITE;
//			else
//				gui_data <= BLACK;