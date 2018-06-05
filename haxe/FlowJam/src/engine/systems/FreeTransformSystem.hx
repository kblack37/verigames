package engine.systems;

import engine.IGameEngine;
import engine.component.BaseComponent;
import engine.component.IComponentManager;
import engine.component.MoveComponent;
import engine.component.RenderableComponent;
import engine.component.RotateComponent;
import engine.component.ScaleComponent;
import engine.component.TransformComponent;
import motion.Actuate;
import openfl.geom.Point;
import utils.XMath;

/**
 * ...
 * @author kristen autumn blackburn
 * 
 * The FreeTransformSystem is responsible for taking the TransformComponents
 * of entities and updating their RenderableComponent to the new transform data
 */
class FreeTransformSystem extends BaseSystem {

	public function new(gameEngine : IGameEngine, id : String = null) {
		super(gameEngine, id);
	}
	
	override public function visit() : Int {
		var componentManager : IComponentManager = m_gameEngine.getComponentManager();
		var renderableComponent : RenderableComponent = null;
		
		// Get all the transform components
		var baseComponents : Array<BaseComponent> = componentManager.getComponentsOfType(TransformComponent.TYPE_ID);
		for (baseComponent in baseComponents) {
			var transformComponent : TransformComponent = try cast(baseComponent, TransformComponent) catch (e : Dynamic) null;
			var entityId : String = transformComponent.id;
			
			// Only update the entities that have a renderable component
			if (componentManager.entityHasComponent(entityId, RenderableComponent.TYPE_ID)) {
				var renderableComponent : RenderableComponent = try cast(componentManager.getComponentByIdAndType(entityId, RenderableComponent.TYPE_ID), RenderableComponent) catch (e : Dynamic) null;
				
				// Update the move first
				var moveComponent : MoveComponent = transformComponent.move;
				if (moveComponent.hasMoveQueued() && !moveComponent.isMoving) {
					moveComponent.updateToQueuedMove();
					
					renderableComponent = try cast(componentManager.getComponentByIdAndType(entityId, RenderableComponent.TYPE_ID), RenderableComponent) catch (e : Dynamic) null;
					if (moveComponent.velocity <= 0) {
						renderableComponent.view.x = moveComponent.x;
						renderableComponent.view.y = moveComponent.y;
					} else {
						var distanceToMove : Float = XMath.getDist(new Point(renderableComponent.view.x, renderableComponent.view.y), new Point(moveComponent.x, moveComponent.y));
						var timeToMove : Float = distanceToMove / moveComponent.velocity;
						Actuate.tween(renderableComponent.view, timeToMove, { x: moveComponent.x, y: moveComponent.y }).onComplete(onMoveComplete, [moveComponent]);
						moveComponent.isMoving = true;
					}
				}
				
				// Update the rotation second
				var rotateComponent : RotateComponent = transformComponent.rotate;
				if (rotateComponent.hasRotationQueued() && !rotateComponent.isRotating) {
					rotateComponent.updateToQueuedRotation();
					
					renderableComponent = try cast(componentManager.getComponentByIdAndType(entityId, RenderableComponent.TYPE_ID), RenderableComponent) catch (e : Dynamic) null;
					if (rotateComponent.angularVelocity <= 0) {
						renderableComponent.view.rotation = rotateComponent.rotation;
					} else {
						var timeToRotate : Float = Math.abs(renderableComponent.view.rotation - rotateComponent.rotation) / rotateComponent.angularVelocity;
						Actuate.tween(renderableComponent.view, timeToRotate, { rotation: rotateComponent.rotation }).smartRotation().onComplete(onRotateComplete, [rotateComponent]);
						rotateComponent.isRotating = true;
					}
				}
				
				// Update the scale last
				var scaleComponent : ScaleComponent = transformComponent.scale;
				if (scaleComponent.hasScaleQueued() && !scaleComponent.isScaling) {
					scaleComponent.updateToQueuedScale();
					
					renderableComponent = try cast(componentManager.getComponentByIdAndType(entityId, RenderableComponent.TYPE_ID), RenderableComponent) catch (e : Dynamic) null;
					if (scaleComponent.scaleVelocity <= 0) {
						renderableComponent.view.scaleX = scaleComponent.scaleX;
						renderableComponent.view.scaleY = scaleComponent.scaleY;
					} else {
						// Do x and y scaling with separate actuators so the longer one defines when the scale is complete
						var timeToScaleX : Float = Math.abs(renderableComponent.view.scaleX - scaleComponent.scaleX) / scaleComponent.scaleVelocity;
						var timeToScaleY : Float = Math.abs(renderableComponent.view.scaleY - scaleComponent.scaleY) / scaleComponent.scaleVelocity;
						var scaleXActuator = Actuate.tween(renderableComponent.view, timeToScaleX, { scaleX: scaleComponent.scaleX });
						var scaleYActuator = Actuate.tween(renderableComponent.view, timeToScaleY, { scaleY: scaleComponent.scaleY });
						
						if (timeToScaleX > timeToScaleY) {
							scaleXActuator.onComplete(onScaleComplete, [scaleComponent]);
						} else {
							scaleYActuator.onComplete(onScaleComplete, [scaleComponent]);
						}
						
						scaleComponent.isScaling = true;
					}
				}
			}
		}
		
		return super.visit();
	}
	
	private function onMoveComplete(moveComponent : MoveComponent) {
		moveComponent.isMoving = false;
	}
	
	private function onRotateComplete(rotateComponent : RotateComponent) {
		rotateComponent.isRotating = false;
	}
	
	private function onScaleComplete(scaleComponent : ScaleComponent) {
		scaleComponent.isScaling = false;
	}
}