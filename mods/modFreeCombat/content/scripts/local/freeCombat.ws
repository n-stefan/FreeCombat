/***********************************************************************/
/** 	Free Combat© 2018 DarkTar All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class CFreeCombat extends IScriptable {

	private var enemyStrafingNoRun: string;
	private var enemyStrafingRun: string;
	private var enemyStrafingOff: string;
	private var jumpingOn: string;
	private var jumpingOff: string;
	private var lootingOn: string;
	private var lootingOff: string;
	private var gameSpeedFast: string;
	private var gameSpeedSlow: string;
	private var gameSpeedPaused: string;
	private var gameSpeedNormal: string;
	private var damageDealtMultiplier: string;
	private var damageTakenMultiplier: string;
	private const var duration: int;
	default duration = 3000;
	
	public function Init()
	{
		InitTexts();
		SetEquipmentDurability();
		RegisterListeners();
	}

	private function InitTexts()
	{
		var option: string;
		var on: string;
		var off: string;
		
		on = GetLocStringByKeyExt("mod_freecombat_on");
		off = GetLocStringByKeyExt("mod_freecombat_off");

		option = GetLocStringByKeyExt("mod_freecombat_enemystrafing");
		enemyStrafingNoRun = option + ": " + GetLocStringByKeyExt("mod_freecombat_enemystrafingnorun");
		enemyStrafingRun = option + ": " + GetLocStringByKeyExt("mod_freecombat_enemystrafingrun");
		enemyStrafingOff = option + ": " + off;

		option = GetLocStringByKeyExt("mod_freecombat_jumping");
		jumpingOn = option + ": " + on;
		jumpingOff = option + ": " + off;

		option = GetLocStringByKeyExt("mod_freecombat_looting");
		lootingOn = option + ": " + on;
		lootingOff = option + ": " + off;

		gameSpeedFast = GetLocStringByKeyExt("mod_freecombat_gamespeedfast");
		gameSpeedSlow = GetLocStringByKeyExt("mod_freecombat_gamespeedslow");
		gameSpeedPaused = GetLocStringByKeyExt("mod_freecombat_gamespeedpaused");
		gameSpeedNormal = GetLocStringByKeyExt("mod_freecombat_gamespeednormal");
		
		damageDealtMultiplier = GetLocStringByKeyExt("mod_freecombat_damagedealtmultiplier");
		damageTakenMultiplier = GetLocStringByKeyExt("mod_freecombat_damagetakenmultiplier");
	}
	
	private function SetEquipmentDurability()
	{
		var chance: int;

		chance = StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('FreeCombat', 'ChanceOfArmorDamage'), 100);
		theGame.params.SetDurabilityArmorLoseChance(chance);

		chance = StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('FreeCombat', 'ChanceOfWeaponDamage'), 100);
		theGame.params.SetDurabilityWeaponLoseChance(chance);
	}

	//private function ResetEquipmentDurability()
	//{
	//	theGame.params.SetDurabilityArmorLoseChance(100);
	//	theGame.params.SetDurabilityWeaponLoseChance(100);
	//}
	
	private function RegisterListeners()
	{
		theInput.RegisterListener(this, 'OnToggleEnemyStrafing', 'ToggleEnemyStrafing');
		theInput.RegisterListener(this, 'OnToggleEnemyStrafingCombat', 'ToggleEnemyStrafingCombat');
		theInput.RegisterListener(this, 'OnToggleJumping', 'ToggleJumping');
		theInput.RegisterListener(this, 'OnToggleLooting', 'ToggleLooting');

		theInput.RegisterListener(this, 'OnCombatJump', 'CbtJump');
		theInput.RegisterListener(this, 'OnCombatTaunt', 'CbtTaunt');

		theInput.RegisterListener(this, 'OnSpeedup', 'Speedup');
		theInput.RegisterListener(this, 'OnSlowdown', 'Slowdown');
		theInput.RegisterListener(this, 'OnPause', 'Pause');
		
		theInput.RegisterListener(this, 'OnDecDamageDealtMultiplier', 'DecDamageDealtMultiplier');
		theInput.RegisterListener(this, 'OnIncDamageDealtMultiplier', 'IncDamageDealtMultiplier');
		theInput.RegisterListener(this, 'OnDecDamageTakenMultiplier', 'DecDamageTakenMultiplier');
		theInput.RegisterListener(this, 'OnIncDamageTakenMultiplier', 'IncDamageTakenMultiplier');
	}

	//private function UnregisterListeners()
	//{
	//	theInput.UnregisterListener(this, 'ToggleEnemyStrafing');
	//	theInput.UnregisterListener(this, 'ToggleEnemyStrafingCombat');
	//	theInput.UnregisterListener(this, 'ToggleJumping');
	//	theInput.UnregisterListener(this, 'ToggleLooting');
    //
	//	theInput.UnregisterListener(this, 'CbtJump');
	//	theInput.UnregisterListener(this, 'CbtTaunt');
    //
	//	theInput.UnregisterListener(this, 'Speedup');
	//	theInput.UnregisterListener(this, 'Slowdown');
	//	theInput.UnregisterListener(this, 'Pause');
	//	
	//	theInput.UnregisterListener(this, 'DecDamageDealtMultiplier');
	//	theInput.UnregisterListener(this, 'IncDamageDealtMultiplier');
	//	theInput.UnregisterListener(this, 'DecDamageTakenMultiplier');
	//	theInput.UnregisterListener(this, 'IncDamageTakenMultiplier');
	//}
	
	private function SetTimeScale(action: SInputAction, scale: float, message: string)
	{
		if (IsPressed(action))
		{
			theGame.SetTimeScale(scale, theGame.GetTimescaleSource(ETS_None), theGame.GetTimescalePriority(ETS_None));
			theGame.GetGuiManager().ShowNotification(message, duration);
		}
		else if (IsReleased(action))
		{
			theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_None));
			theGame.GetGuiManager().ShowNotification(gameSpeedNormal, duration);
		}
	}

	private function SetDamageMultiplier(action: SInputAction, type: name, message: string, increase: bool)
	{
		var damageMultiplier: float;
		
		if (IsPressed(action))
		{
			damageMultiplier = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('FreeCombat', type), 1);

			if (increase)
			{
				damageMultiplier += 0.1;
				if (damageMultiplier > 2)
					damageMultiplier = 2;
			}
			else
			{
				damageMultiplier -= 0.1;
				if (damageMultiplier < 0.5)
					damageMultiplier = 0.5;
			}

			theGame.GetGuiManager().ShowNotification(message + ": " + NoTrailZeros(damageMultiplier), duration);

			theGame.GetInGameConfigWrapper().SetVarValue('FreeCombat', type, damageMultiplier);
			theGame.SaveUserSettings();
		}
	}

	event OnSpeedup(action: SInputAction)
	{
		SetTimeScale(action, 4, gameSpeedFast);
	}
	
	event OnSlowdown(action: SInputAction)
	{
		SetTimeScale(action, 0.25, gameSpeedSlow);
	}

	event OnPause(action: SInputAction)
	{
		SetTimeScale(action, 0, gameSpeedPaused);
	}

	event OnDecDamageDealtMultiplier(action: SInputAction)
	{
		SetDamageMultiplier(action, 'DamageDealtMultiplier', damageDealtMultiplier, false);
	}
	
	event OnIncDamageDealtMultiplier(action: SInputAction)
	{
		SetDamageMultiplier(action, 'DamageDealtMultiplier', damageDealtMultiplier, true);
	}
	
	event OnDecDamageTakenMultiplier(action: SInputAction)
	{
		SetDamageMultiplier(action, 'DamageTakenMultiplier', damageTakenMultiplier, false);
	}
	
	event OnIncDamageTakenMultiplier(action: SInputAction)
	{
		SetDamageMultiplier(action, 'DamageTakenMultiplier', damageTakenMultiplier, true);
	}

	event OnToggleEnemyStrafing(action: SInputAction)
	{
		var enemyStrafing: string;
		
		if (IsPressed(action))
		{
			enemyStrafing = theGame.GetInGameConfigWrapper().GetVarValue('FreeCombat', 'EnemyStrafing');

			if (enemyStrafing == "0")
			{
				enemyStrafing = "1";
				theGame.GetGuiManager().ShowNotification(enemyStrafingRun, duration);
			}
			else if (enemyStrafing == "1")
			{
				enemyStrafing = "2";
				theGame.GetGuiManager().ShowNotification(enemyStrafingOff, duration);
			}
			else if (enemyStrafing == "2")
			{
				enemyStrafing = "0";
				theGame.GetGuiManager().ShowNotification(enemyStrafingNoRun, duration);
			}

			theGame.GetInGameConfigWrapper().SetVarValue('FreeCombat', 'EnemyStrafing', enemyStrafing);
			theGame.SaveUserSettings();
		}
	}

	event OnToggleEnemyStrafingCombat(action: SInputAction)
	{
		var enemyStrafing: string;
		
		if (IsPressed(action))
		{
			enemyStrafing = theGame.GetInGameConfigWrapper().GetVarValue('FreeCombat', 'EnemyStrafing');

			if (enemyStrafing == "0")
			{
				enemyStrafing = "1";
				theGame.GetGuiManager().ShowNotification(enemyStrafingRun, duration);
			}
			else
			{
				enemyStrafing = "0";
				theGame.GetGuiManager().ShowNotification(enemyStrafingNoRun, duration);
			}

			theGame.GetInGameConfigWrapper().SetVarValue('FreeCombat', 'EnemyStrafing', enemyStrafing);
			theGame.SaveUserSettings();
		}
	}

	event OnToggleJumping(action: SInputAction)
	{
		var jumping: bool;
		
		if (IsPressed(action))
		{
			jumping = theGame.GetInGameConfigWrapper().GetVarValue('FreeCombat', 'Jumping');
			
			jumping = !jumping;
			
			if (jumping)
				theGame.GetGuiManager().ShowNotification(jumpingOn, duration);
			else
				theGame.GetGuiManager().ShowNotification(jumpingOff, duration);

			theGame.GetInGameConfigWrapper().SetVarValue('FreeCombat', 'Jumping', jumping);
			theGame.SaveUserSettings();
		}
	}
	
	event OnToggleLooting(action: SInputAction)
	{
		var looting: bool;
		
		if (IsPressed(action))
		{
			looting = theGame.GetInGameConfigWrapper().GetVarValue('FreeCombat', 'Looting');
			
			looting = !looting;
			
			if (looting)
				theGame.GetGuiManager().ShowNotification(lootingOn, duration);
			else
				theGame.GetGuiManager().ShowNotification(lootingOff, duration);

			theGame.GetInGameConfigWrapper().SetVarValue('FreeCombat', 'Looting', looting);
			theGame.SaveUserSettings();
		}
	}

	event OnCombatJump(action: SInputAction)
	{
		var jumping: bool;
		
		jumping = theGame.GetInGameConfigWrapper().GetVarValue('FreeCombat', 'Jumping');
		
		if (jumping && IsPressed(action))
			thePlayer.substateManager.QueueStateExternal('Jump');
	}

	event OnCombatTaunt(action: SInputAction)
	{
		if (IsPressed(action))
		{
			if (thePlayer.RaiseEvent('CombatTaunt'))
				thePlayer.PlayVoiceset(90, 'BattleCryTaunt');
		}
	}
}
