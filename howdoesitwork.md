Let me explain how ElasticTransition work by breaking it down into three parts, you can skip to the section that interest you the most.

1. Drawing the curved shape
2. View Hierarchy & Layout
3. Animation

#Drawing the curved shape

This is done by **ElasticShapeLayer**.
It is basically a CAShapeLayer with a custom path. The path is defined by four attributes:

1. frame
2. edge
3. radiusFactor
4. dragPoint

frame and edge are easy to understand. the radiusFactor defines the curvature of the edge when dragged. the dragPoint is the center of the curved edge.

Here is how the path is drawn:



Note that is the simpler drawing method which is used when radiusFactor >= 0.5.
For radiusFactor below 0.5 please see ElasticShapeLayer.swift


# View Hierarchy & Layout

Two things are happening.
1. contentView is sliding on to the screen
2. shapeLayer's frame and dragPoint are updated

# Animation

I used UIKitDynamic to animate the curved shape to give it a more realistic bouncy feeling.
