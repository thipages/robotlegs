/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package org.robotlegs.base
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.getDefinitionByName;
	
	import org.robotlegs.core.IMediator;
	
	/**
	 * Abstract <code>IMediator</code> and <code>IPropertyProvider</code> implementation
	 */
	public class MediatorBase implements IMediator
	{
		/**
		 * A demonstration of Flex's poor design part #1
		 */
		private static var UIComponentClass:Class;
		
		/**
		 * A demonstration of Flex's poor design part #2
		 */
		private static const flexAvailable:Boolean = checkFlex();
		
		/**
		 * Internal
		 *
		 * This Mediator's View Component, used by the RobotLegs MVCS framework internally.
		 * You should declare a dependency on a concrete view component in your
		 * implementation instead of working with this property
		 */
		protected var viewComponent:Object;
		
		/**
		 * Internal
		 *
		 * A list of currently registered listeners
		 */
		protected var listeners:Array;
		
		/**
		 * Creates a new <code>Mediator</code> object
		 */
		public function MediatorBase()
		{
			listeners = new Array();
		}
		
		/**
		 * @inheritDoc
		 */
		public function preRegister():void
		{
			if (flexAvailable && (viewComponent is UIComponentClass) && !viewComponent['initialized'])
			{
				IEventDispatcher(viewComponent).addEventListener('creationComplete', onCreationComplete, false, 0, true);
			}
			else
			{
				onRegister();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function onRegister():void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function preRemove():void
		{
			removeListeners();
			onRemove();
		}
		
		/**
		 * @inheritDoc
		 */
		public function onRemove():void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function getViewComponent():Object
		{
			return viewComponent;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setViewComponent(viewComponent:Object):void
		{
			this.viewComponent = viewComponent;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function provideProperty(name:String, type:*):*
		{
			return null;
		}
		
		/**
		 * addEventListener Helper method
		 *
		 * The same as calling <code>addEventListener</code> directly on the <code>IEventDispatcher</code>,
		 * but keeps a list of listeners for easy (usually automatic) removal.
		 *
		 * @param dispatcher The <code>IEventDispatcher</code> to listen to
		 * @param type The <code>Event</code> type to listen for
		 * @param listener The <code>Event</code> handler
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 */
		protected function addEventListenerTo(dispatcher:IEventDispatcher, type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
		{
			// TODO: make weak - currently the listeners array keeps strong references.. bad
			var params:Object = {dispatcher: dispatcher, type: type, listener: listener, useCapture: useCapture};
			listeners.push(params);
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * removeEventListener Helper method
		 *
		 * The same as calling <code>removeEventListener</code> directly on the <code>IEventDispatcher</code>,
		 * but updates our local list of listeners.
		 *
		 * @param dispatcher The <code>IEventDispatcher</code>
		 * @param type The <code>Event</code> type
		 * @param listener The <code>Event</code> handler
		 * @param useCapture
		 */
		protected function removeEventListenerFrom(dispatcher:IEventDispatcher, type:String, listener:Function, useCapture:Boolean = false):void
		{
			var params:Object;
			var i:int = listeners.length;
			while (i--)
			{
				params = listeners[i];
				if (params.dispatcher == dispatcher && params.type == type && params.listener == listener && params.useCapture == useCapture)
				{
					dispatcher.removeEventListener(type, listener, useCapture);
					listeners.splice(i, 1);
					return;
				}
			}
		}
		
		/**
		 * Removes all listeners registered through <code>addEventListenerTo</code>
		 */
		protected function removeListeners():void
		{
			var params:Object;
			var dispatcher:IEventDispatcher;
			while (params = listeners.pop())
			{
				dispatcher = params.dispatcher;
				dispatcher.removeEventListener(params.type, params.listener, params.useCapture);
			}
		}
		
		/**
		 * A demonstration of Flex's poor design part #3
		 * 
		 * Checks for availability of the Flex framework by trying to get the class for UIComponent.
		 */
		private static function checkFlex():Boolean
		{
			try
			{
				UIComponentClass = getDefinitionByName('mx.core::UIComponent') as Class;
			}
			catch (error:Error)
			{
				// do nothing
			}
			return UIComponentClass != null;
		}
		
		/**
		 * A demonstration of Flex's poor design part #4
		 * 
		 * FlexEvent.CREATION_COMPLETE handler for this Mediator's View Component
		 *
		 * @param e The Flex Event
		 */
		private function onCreationComplete(e:Event):void
		{
			IEventDispatcher(e.target).removeEventListener('creationComplete', onCreationComplete);
			onRegister();
		}
	}
}
