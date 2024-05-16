<h1>Snek</h1>
<p>Snake game written in 8086 assembly</p>
<p align="center">
  <img style="width:500px" src="https://github.com/chaotic-braindead/snake-8086-asm/blob/main/demo.gif?raw=true" alt="snek demo">
</p>
<h1>random walls update changes:</h1>
<p>Added active_wall_pos, this will be the set of walls used for the game session</p>
<p>load_walls proc, will randomly choose one of two hard/med levels based on the chosen difficulty (this will be called from diff_page)</p>
<p>replaced calls of hard_pos and med_pos to active_wall_pos</p>
