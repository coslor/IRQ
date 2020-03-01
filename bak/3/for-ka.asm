.pseudocommand mov src:foo {
src_label:				lda foo 
}


/*
.pseudocommand my_for index1:start:end {
index1:				.byte <start,>end

for_index1:
					lda index1+1
					cmp #>end
					bne loop_index1
					lda index1
					cmp #<end
					bne loop_index1
					beq index_:end
loop_index1:					
					inc index1
					bne index1_continue
					inc index1+1
index1_continue: 
 					
}
*/

*=$c000
stuff:				.byte $ff

					mov junk : stuff
//my_for v:1:1000 
/*
.pseudocommand my_next index2 {
next_index2:
					clc
					bcc for_:index2
					
index2:_end					
}					
*/

.var stk_lvl5 = 0
.var stk_lvl4 = 0
.var stk_lvl3 = 0
.var stk_lvl2 = 0
.var stk_lvl1 = 0

.macro 				IF_EQ {
					bne *
					PUSH 
					
}
.macro 				PUSH {
		.eval stk_lvl5 = stk_lev4 
		.eval stk_lvl4 = stk_lvl3 
		.eval stk_lvl3 = stk_lev2 
		.eval stk_lvl2 = stk_lvl1 
		.eval stk_lvl1 = to_push1 
} 
 
