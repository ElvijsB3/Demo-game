-- Dependencies

require("entities.player")
require("entities.enemy")
require("core.collision")

debug = true

isAlive = true
score = 0
highscore = 0

-- Timers
	-- We declare these here so we don't have to edit them multiple places
		canShoot = true
		canShootTimerMax = 0.2 
		canShootTimer = canShootTimerMax
	-- Enemy timer
		createEnemyTimerMax = 0.4
		createEnemyTimer = createEnemyTimerMax

-- Image Storage
	bulletImg = nil
	enemyImg = nil -- Like other images we'll pull this in during out love.load function

-- Entity Storage
	player = { x = 200, y = 710, speed = 150, img = nil }
	bullets = {} -- array of current bullets being drawn and updated
	enemies = {} -- array of current enemies on screen

function love.load(arg)
	-- Images
	    player.img = love.graphics.newImage('assets/plane.png')
	    bulletImg = love.graphics.newImage('assets/bullet.png')
	    enemyImg = love.graphics.newImage('assets/enemy.png')
	    gBackground = love.graphics.newImage('assets/background.png')
	-- Music
		bGsound = love.audio.newSource("assets/music/background_music.mp3")
		love.audio.play(bGsound)

		gunSound = love.audio.newSource("assets/gun-sound.wav", "static")
	-- Savegame
	   if love.filesystem.exists("name.sav") then -- Checks if the file exists
	      highscore = love.filesystem.read("name.sav") -- Reads the file to get the name
	   else
	      love.filesystem.newFile("name.sav") -- Create a new file
	      score = ""
	      love.filesystem.write("name.sav", score) -- Write the empty name
	   end
end

function love.update(dt)
	-- I always start with an easy way to exit the game
		if love.keyboard.isDown('escape') then
			love.event.push('quit')
		end

	-- Movement
		if love.keyboard.isDown('left','a') then
			if player.x > 0 then -- binds us to the map
				player.x = player.x - (player.speed*dt)
			end
		elseif love.keyboard.isDown('right','d') then
			if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
				player.x = player.x + (player.speed*dt)
			end
		end

		-- Vertical movement
		if love.keyboard.isDown('up', 'w') then
			if player.y > (love.graphics.getHeight() / 2) then
				player.y = player.y - (player.speed*dt)
			end
		elseif love.keyboard.isDown('down', 's') then
			if player.y < (love.graphics.getHeight() - 55) then
				player.y = player.y + (player.speed*dt)
			end
		end
	-- Shooting
		if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
			-- Create some bullets
			newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
			table.insert(bullets, newBullet)
			canShoot = false
			canShootTimer = canShootTimerMax
		end

		-- Bullet loop
			canShootTimer = canShootTimer - (1 * dt)
			if canShootTimer < 0 then
			  canShoot = true
			end

			-- update the positions of bullets
			for i, bullet in ipairs(bullets) do
				bullet.y = bullet.y - (250 * dt)

			  	if bullet.y < 0 then -- remove bullets when they pass off the screen
					table.remove(bullets, i)
				end
			end
	-- Enemy
		-- Time out enemy creation
			createEnemyTimer = createEnemyTimer - (1 * dt)
			if createEnemyTimer < 0 then
				createEnemyTimer = createEnemyTimerMax

				-- Create an enemy
				randomNumber = math.random(10, love.graphics.getWidth() - 10)
				newEnemy = { x = randomNumber, y = -10, img = enemyImg }
				table.insert(enemies, newEnemy)
			end	
		-- update the positions of enemies
			for i, enemy in ipairs(enemies) do
				enemy.y = enemy.y + (200 * dt)

				if enemy.y > 850 then -- remove enemies when they pass off the screen
					table.remove(enemies, i)
				end
			end	
	-- Gun sounds
		if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
			-- Create some bullets
			newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
			table.insert(bullets, newBullet)
			--NEW LINE
		    gunSound:play()
		    gunSound:setVolume(0.1)
		    --END NEW
		    canShoot = false
			canShootTimer = canShootTimerMax
		end
	-- run our collision detection
		-- Since there will be fewer enemies on screen than bullets we'll loop them first
		-- Also, we need to see if the enemies hit our player
		for i, enemy in ipairs(enemies) do
			for j, bullet in ipairs(bullets) do
				if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
					table.remove(bullets, j)
					table.remove(enemies, i)
					score = score + 1
				end
			end

			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) 
			and isAlive then
				table.remove(enemies, i)
				isAlive = false
			end					
	end

	-- Restart update
		if not isAlive and love.keyboard.isDown('r') then
			-- remove all our bullets and enemies from screen
			bullets = {}
			enemies = {}

			-- reset timers
			canShootTimer = canShootTimerMax
			createEnemyTimer = createEnemyTimerMax

			-- move player back to default position
			player.x = 50
			player.y = 710

			-- reset our game state
			score = 0
			isAlive = true
		end

	-- Highscore update

	highscore = score

	if score > highscore then
		love.filesystem.write("name.sav", score) -- Write the empty name
	end
end

function love.draw(dt)
	love.graphics.draw(gBackground, 0,0)

	if isAlive then
		love.graphics.draw(player.img, player.x, player.y)
		love.graphics.print("Score:", 15, 15)
		love.graphics.print(score, 60, 15)
	else
		love.audio.setVolume(0.3) 
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)

	end

	for i, bullet in ipairs(bullets) do
	  love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
	end
end