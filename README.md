## Overview
LOVE-Projections renders 3D models (*.obj files*) by projecting them onto 2D space using a strong perspective projection approach. A primitive shader has been added, but z-buffering proved beyond my skill set, entirely ruining the effect.

## How to Run
To run LOVE-Projections, simply execute the LOVE-Projections.exe under the LOVE-Projections-build file.

## Methods
[Perspective Projection](https://en.wikipedia.org/wiki/3D_projection#Perspective_projection) simulates the action of a pinhole camera, allowing for a good amount of depth perspective. I started creating the shader by taking the dot product of the cross product of two edges of a face and a vector towards the light source. This product could then easily be used to shade the RGB values of a polygon. Unfortunately, it became difficult and downright slow to make it so elements wouldn't render over each other. I tried to implement a z-buffer using [z-culling](https://en.wikipedia.org/wiki/Z-buffering#Z-culling), not rendering polygons the farthest away. Unfortunatly, this turned out as effective as you would think it would. Much slower too!

## Takeaways
I didn't have nearly as much using matrices and vectors for graphics transformations before this project. When starting, I felt nearly helpless. You can only imagine the wonky shapes I had to witness in the creation of this project. I also don't think I have ever spent as much time reading wikipedia and online articles in order to get my project to work, so suffice to say I am proud of my own ability to learn and pick up on new information quickly. I also spent a fair amount of time getting practice on the linux command line.

Overall, I crushed my initial hopes of simply being able to render a box into loading object files and performing tricky computations. The project was much harder than I thought it would be and I am so happy with the output I got.

## Future
From some talk I have had with peers on computer graphics, I think it would be possible to write shader code in LOVE using GLSL, which would provide the outputs I strived for the whole event. That is, beautiful z-buffering and shading! It was so bland staring at a black and white model the entire time, it would definitely be a goal to introduce some normal mapping.

## Credits
Source|File(s)
---|---
Adrian Alberto|vector.lua
Michael Lutz, David Manura|matrix.lua
Landon Manning|loader.lua
[Objects](https://people.sc.fsu.edu/~jburkardt/data/obj/obj.html)|object files

LOVE-Projections is written in lua and brought to life by the *amazing* LOVE2D engine.
https://love2d.org/

Knight Hacks 2019
https://knighthacks.org/

Made with love.
Thanks for reading!
