package 
{

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.events.*;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class chomp extends MovieClip
	{
		
		private static const amTesting:Boolean = false;
		
		//Stage scrolling mechanism constants
		private static const stageEdgeMinimumDistance:uint  = 400; 			// Minimum distance from edge to activate background scrolling.
		private static const stageScrollSpeed:uint 			= 8;			// Speed of stage scrolling; larger numbers produce slower scrolling.
		
		//Enemy Constants
		private static const enemyGenTimeMiliSeconds:uint 	= 500;			// How often new enemies are generated.
		
		private static const baseEnemySpeed:uint 			= 20			// Base speed in pixels that enemies move when not agitated.
		private static const fleeSpeedBoostBaseValue:uint 	= 40;			// How much faster enemies will move when cursor is nearby.
		private static const enemyFleeDistance:uint 		= 200;			// How close in pixels the cursor must be to an enemy for it to flee.
		
		private static const enemyLowerThreshold:uint 		= 5;			// When the # of enemies on screen is this low, we increase generation of new ones.
		private static const enemyNormalAmount:uint 		= 2;			// How many enemies to generate on each cycle when enemies are not "low."
	
		private static const enemyPoints:uint 				= 1;			// How much eating a single enemy adds to the score.
		
		//Cursor Color-change Constants
		private static const blue:uint = 0;
		private static const red:uint = 3;
		private static const black:uint = 6;
		private static const green:uint = 9;
		private static const darkblue:uint = 12;
		private static const orange:uint = 15;
		private static const white:uint = 18;
		private static const brown:uint = 21;


		public function chomp() {
			box.visible = false;
			
			/// Initialize background image.
			var backgroundImage:background = new background();
			var backgroundImageWidth:uint = backgroundImage.width;
			var backgroundImageHeight:uint = backgroundImage.height;
			backgroundImage.cacheAsBitmap = true;
			backgroundImage.scrollRect = new Rectangle(300, 300,stage.stageWidth,stage.stageHeight);
			addChild(backgroundImage);

			backgroundImage.addEventListener(Event.ENTER_FRAME, updateBackground);

			// Initialize text.
			var score:uint = 0;
			var scoreTextField:TextField = new TextField();
			scoreTextField.width = stage.stageWidth;
			var scoreTextSyle:TextFormat = new TextFormat();
			scoreTextSyle.font = "Arial";
			scoreTextSyle.color = 0xFFFFFF;
			scoreTextSyle.size = 30;
			scoreTextField.defaultTextFormat = scoreTextSyle;

			addChild(scoreTextField);

			//Code for keeping the cursor going
			
			var cursorColor:uint;
			var chomper:cursor = new cursor();
			chomper.gotoAndStop(1 + cursorColor);
			chomper.x = mouseX;
			chomper.y = mouseY;
			chomper.mouseEnabled = false;
			chomper.mouseChildren = false;
			Mouse.hide();
			chomper.facingLeft = true;
			
			
			chomper.addEventListener(Event.ENTER_FRAME, updateGame);
			
			
			

			// Helper functions for enemy collision detection.
			
			// Returns x coordinate of enemy passed in.
			function enemyX(enm:MovieClip):int
			{
				return (enm.x - backgroundImage.scrollRect.x);
			}
			
			// Returns y coordinate of enemy passed in.
			function enemyY(enm:MovieClip):int
			{
				return (enm.y - backgroundImage.scrollRect.y);
			}			
			
			// Screen update function to be run on every frame.
			function updateGame(event:Event)
			{
				
				// Function to show cursor color-swap options box.
				function makeColorBoxVisible(evt:MouseEvent) {
					box.visible = !box.visible;
				}
				// Change cursor sprite color.
				function changeColor(evt:MouseEvent) {
					Mouse.hide();
					if (box.LIGHTBLUE1.hitTestPoint(mouseX, mouseY, false)) {
						cursorColor = blue;
						chomper.gotoAndStop(1 + cursorColor);
					} else if (box.RED1.hitTestPoint(mouseX, mouseY, false)) {
						cursorColor = red;
						chomper.gotoAndStop(1 + cursorColor);
					} else if (box.BLACK1.hitTestPoint(mouseX, mouseY, false)) {
						cursorColor = black;
						chomper.gotoAndStop(1 + cursorColor);
					} else if (box.GREEN1.hitTestPoint(mouseX, mouseY, false)) {
						cursorColor = green;
						chomper.gotoAndStop(1 + cursorColor);
					} else if (box.DARKBLUE1.hitTestPoint(mouseX, mouseY, false)) {
						cursorColor = darkblue;
						chomper.gotoAndStop(1 + cursorColor);
					} else if (box.ORANGE1.hitTestPoint(mouseX, mouseY, false)) {
						cursorColor = orange;
						chomper.gotoAndStop(1 + cursorColor);
					} else if (box.WHITE1.hitTestPoint(mouseX, mouseY, false)) {
						cursorColor = white;
						chomper.gotoAndStop(1 + cursorColor);
					} else if (box.BROWN1.hitTestPoint(mouseX, mouseY, false)) {
						cursorColor = brown;
						chomper.gotoAndStop(1 + cursorColor);
					}
				}
				
				// Check if user is hovering over color-swap box or button and show (non-sprite) cursor if so.
				if(colorButton.hitTestPoint(mouseX, mouseY, true) || box.hitTestPoint(mouseX, mouseY, true)) {
					Mouse.show();
				}
				else {
					Mouse.hide();
				}
			
				// If user clicks button to open color-swap options box, display the box.
				colorButton.addEventListener(MouseEvent.CLICK, makeColorBoxVisible);
				
				// If user clicks inside the color-swap options box, change the color of the cursor sprite as appropriate.
				box.addEventListener(MouseEvent.CLICK, changeColor);
	
				// Record previous cursor position
				var lastX:int = chomper.x;
					
				// Flip sprite if moving in opposite direction from before
				if (chomper.facingLeft &&  (mouseX > lastX))
				{
					chomper.scaleX *=  -1;
					chomper.facingLeft = false;
				}
				else if (!chomper.facingLeft &&  (mouseX < lastX))
				{
					chomper.scaleX *=  -1;
					chomper.facingLeft = true;
				}
				// Update cursor position
				chomper.x = mouseX;
				chomper.y = mouseY;
	
				//Check for enemy collisions and respond appropriately
				for (var i:uint = 0; i < enemyArray.length; i++)
				{
					// If enemy is outside the boundaries of the stage significantly, remove it
					if (enemyX(enemyArray[i]) <= -200 ||
					   enemyX(enemyArray[i]) >= stage.stageWidth + 200 ||
					   enemyY(enemyArray[i]) <= -200 ||
					   enemyY(enemyArray[i]) >=  stage.stageHeight + 200 )
					{
						backgroundImage.removeChild(enemyArray[i]);
						enemyArray.splice(i, 1);
						continue;
					}
					// If enemy comes within certain distance of cursor, activate its fleeing state
					if (distanceFormula(chomper,enemyArray[i]) < enemyFleeDistance)
					{
						enemyArray[i].isFleeing = true;
					}
	
					// If cursor collides with enemy, animate cursor, remove enemy and update score appropriately
					if (chomper.hitTestObject(enemyArray[i]))
					{
						chomper.gotoAndStop(2 + cursorColor);
						var biteAnimationTimer:Timer = new Timer(70,1);
						biteAnimationTimer.addEventListener(TimerEvent.TIMER, biteAnimation);
						biteAnimationTimer.start();
						function biteAnimation(evt:TimerEvent)
						{
							chomper.gotoAndStop(3 + cursorColor);
							openMouthTimer.start();
						}
						backgroundImage.removeChild(enemyArray[i]);
						enemyArray.splice(i, 1);
						score +=  enemyPoints;
						var canSelect:Boolean = false;
						
						// Set cursor color based on score thresholds or enable ability to choose color
						if(score <= 700 || !amTesting) {
							if(score >= 700){
								cursorColor = brown;
								canSelect = true;
							}
							else if(score >= 600) cursorColor = white;
							else if(score >= 500) cursorColor = orange;
							else if(score >= 400) cursorColor = darkblue;
							else if(score >= 300) cursorColor = green;
							else if(score >= 200) cursorColor = black;
							else if(score >= 100) cursorColor = red;
						}
						// Set challenge / score text
						if (score > 600 && score < 700) {
							scoreTextField.text = String("this is impossible. how. could you really eat " + (700 - score) + " \nMORE APPLES?");
						}
						else if (score > 500 && score < 600) {
							scoreTextField.text = String("good lord. i DARE you to eat " + (600 - score) + " MORE APPLES.");
						}
						else if (score > 400 && score < 500) {
							scoreTextField.text = String("ok OK but can you eat " + (500 - score) + " MORE apples?");
						}
						else if (score > 300 && score < 400) {
							scoreTextField.text = String(" OK......." + (400 - score) + " more apples.");
						}
						else if (score > 200 && score < 300) {
							scoreTextField.text = String("OK. sure. now eat " + (300 - score) + " apples.");
						}
						else if (score > 100 && score < 200) {
							scoreTextField.text = String("now please eat " + (200 - score) + " apples.");
						}
						else if (score < 100)
						{
							scoreTextField.text = String("please eat " + (100 - score) + " apples.");
						}
						else if(score > 700)
						{
							scoreTextField.text = String("congratulations, you've eaten " + (score * 95) + " calories worth of apples");
						}
						else {
							scoreTextField.text = String("WOW!");
						}
	
	
					}
				}
	
				// Add cursor to stage
				addChild(chomper);
				// Add color-swap options box to stage if appropriate
				if(canSelect || amTesting) {
					addChild(box);
					addChild(colorButton);
				}
	
			}

			// Cursor bite animation: opening mouth timing
			var openMouthTimer:Timer = new Timer(500,1);
			openMouthTimer.addEventListener(TimerEvent.TIMER, openMouth);
			function openMouth()
			{
				chomper.gotoAndStop(1 + cursorColor);
			}

			// Enemy movement timers for randomized movement events
			var enemyMoveTimer:Timer = new Timer(50);
			enemyMoveTimer.addEventListener(TimerEvent.TIMER, enemyMove);
			var enemyFlipTimer:Timer = new Timer(1000);
			enemyFlipTimer.addEventListener(TimerEvent.TIMER, enemyFlip);
			var enemyFlipChance:Boolean = false;
			function enemyFlip(evt:TimerEvent)
			{
				if (Math.random() < .3)
				{
					enemyFlipChance = true;
				}
				else
				{
					enemyFlipChance = false;
				}
			}
			function enemyMove()
			{
				for (var i:uint = 0; i < enemyArray.length; i++)
				{
					// Flip enemy sprite movement direction randomly
					if (enemyFlipChance)
					{
						enemyFlipChance = false;
						if (Math.random() < .5)
						{
							enemyArray[i].scaleX *=  -1;
							enemyArray[i].goesLeft *=  -1;
						}

					}
					// Change enemy sprite altitude randomly.
					if (Math.random() < .4)
					{
						if (Math.random() < .5)
						{
							enemyArray[i].y +=  1;
						}
						else
						{
							enemyArray[i].y -=  1;
						}
					}

					// Have enemy flee from cursor if set to fleeing state
					if (enemyArray[i].isFleeing)
					{
						var fleeSpeedBoost:uint = fleeSpeedBoostBaseValue;


						if (enemyArray[i].goesLeft == 1 && enemyX(enemyArray[i]) > chomper.x)
						{
							enemyArray[i].scaleX *=  -1;
							enemyArray[i].goesLeft *=  -1;
						}
						else if (enemyArray[i].goesLeft != 1 && enemyX(enemyArray[i]) < chomper.x )
						{
							enemyArray[i].scaleX *=  -1;
							enemyArray[i].goesLeft *=  -1;
						}
					}
					else
					{
						fleeSpeedBoost = 0;
					}

					// Move enemy sprite based on previous calculations
					enemyArray[i].x -=  (baseEnemySpeed * enemyArray[i].speedMultiplier + 2 + fleeSpeedBoost) * enemyArray[i].goesLeft;
				}
			}
			enemyMoveTimer.start();
			enemyFlipTimer.start();


			// Generate enemies periodically
			var enemyArray:Array = new Array();
			var enemyCreationTimer:Timer = new Timer(enemyGenTimeMiliSeconds);
			enemyCreationTimer.addEventListener(TimerEvent.TIMER, createEnemy);
			function createEnemy(evt:TimerEvent)
			{
				//If reach lower threshold for number of enemies, make more! (Double total)
				if (enemyArray.length < enemyLowerThreshold)
				{
					var howManyEnemiesToCreate:uint = enemyLowerThreshold;
				}
				else
				{
					howManyEnemiesToCreate = enemyNormalAmount;
				}
				for (var i:uint = 0; i < howManyEnemiesToCreate; i++)
				{
					var newEnemy:enemy = new enemy();
					newEnemy.goesLeft = Math.floor(Math.random() * 2);
					if (newEnemy.goesLeft == 0)
					{
						newEnemy.scaleX *=  -1;
						newEnemy.goesLeft = -1; //This will be used as a multiplier for x-coordinate change.
					}
					var newY:uint = Math.floor(Math.random() * stage.stageHeight) + backgroundImage.scrollRect.y;
					if (newEnemy.goesLeft == 1)
					{
						newEnemy.x = (backgroundImage.scrollRect.x + stage.stageWidth) + (Math.random() * 50) + 25;
					}
					else
					{
						newEnemy.x = backgroundImage.scrollRect.x -((Math.random() * 50) + 25);
					}
					newEnemy.y = newY;
					newEnemy.speedMultiplier = Math.random();
					newEnemy.isFleeing = false;
					enemyArray.push(newEnemy);
					backgroundImage.addChild(newEnemy);
				}
			}
			enemyCreationTimer.start();

			// Scroll background with cursor movement appropriately.
			function updateBackground(event:Event):void
			{
				var newScrollRect:Rectangle = backgroundImage.scrollRect;

				function newPositionFinder()
				{
					var y_pos:Number = ((Math.abs(backgroundImage.y - mouseY)/newScrollRect.height)*(backgroundImageHeight-newScrollRect.height));
					var x_pos:Number = ((Math.abs(backgroundImage.x - mouseX)/newScrollRect.width)*(backgroundImageWidth-newScrollRect.width));

					newScrollRect.x += (x_pos - newScrollRect.x)/stageScrollSpeed;
					newScrollRect.y += (y_pos - newScrollRect.y)/stageScrollSpeed;
				}

				if (mouseX > (stage.stageWidth - stageEdgeMinimumDistance) || mouseX < stageEdgeMinimumDistance 
				|| mouseY > (stage.stageHeight - stageEdgeMinimumDistance) || mouseY < stageEdgeMinimumDistance)
				{
					newPositionFinder();
				}
				backgroundImage.scrollRect = newScrollRect;
			}

			// Return distance in pixels between cursor sprite and a given enemy sprite.
			function distanceFormula(chomperInternalF:MovieClip, enemyInternalF:MovieClip):Number
			{
				return Math.sqrt(Math.pow(((enemyInternalF.x - backgroundImage.scrollRect.x) - chomperInternalF.x),2) + Math.pow(((enemyInternalF.y - backgroundImage.scrollRect.y) - chomperInternalF.y),2));
			}
		}

	}

}