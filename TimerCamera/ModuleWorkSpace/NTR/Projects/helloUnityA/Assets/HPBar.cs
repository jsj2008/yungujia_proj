using UnityEngine;
using System.Collections;

public class HPBar : MonoBehaviour {

	private Camera camera;
	private string name = "牛头人の精力♂";
	private string infoString = "欢迎来到牛头人の哲♂学世界";
	
	GameObject hero;
	float npcHeight;
	public Texture2D blood_red;
	public Texture2D blood_black;
    private int HP = 100;
	private string labelText = null;
	private const int HPLossStep = 3;
	
	public Texture2D talkBoxText;
	
	private const string INFO_START = "欢迎来到牛头人の哲♂学世界，1~4指获得快♂乐";
	private const string INFO_NO_ENERGY = "雅蠛蝶~~ (三指为牛头人服务)";
	private const string INFO_FULL_ENERGY = "我是一只精力充沛的牛头人，亚拉那一卡！";
	private const string INFO_USING_ENERGY = "啊♂~~~（牛头人发动溅射攻击）";
	
	enum HealState
	{
		HST_START = 0,
		HST_USING = 1,
		HST_USED = 2,
		HST_RECOVERD = 3,
	};
	
	private HealState healState;
	
	void Start ()
	{
		hero = GameObject.FindGameObjectWithTag("Player");
		camera = Camera.main;

		float size_y = collider.bounds.size.y;
		float scal_y = transform.localScale.y;
		npcHeight = (size_y *scal_y) ;
		
		healState = HealState.HST_START;
		
	}

	void Update ()
	{
		//transform.LookAt(hero.transform);
		if(Input.GetMouseButtonDown(0) || (Input.touchCount == 1))
		{
			if(HP > HPLossStep)
			{
				HP -= HPLossStep;
				healState = HealState.HST_USING;
			}
			else
			{
				HP = 0;
				healState = HealState.HST_USED;
			}
		}
		
		if(Input.GetMouseButtonDown(1) || (Input.touchCount == 4))
		{
			HP = 100;
			healState = HealState.HST_RECOVERD;
		}
	}
	
	void updateInfoString()
	{
		switch(healState)
		{
		case HealState.HST_USING:
			infoString = INFO_USING_ENERGY;
			break;
		case HealState.HST_USED:
			infoString = INFO_NO_ENERGY;
			break;
		case HealState.HST_RECOVERD:
			infoString = INFO_FULL_ENERGY;
			break;
		case HealState.HST_START:
			infoString = INFO_START;
			break;
		default:
			break;
		}
	}

	void OnGUI()
	{
		Vector3 worldPosition = new Vector3 (transform.position.x , transform.position.y + npcHeight,transform.position.z);
		Vector2 position = camera.WorldToScreenPoint (worldPosition);
		position = new Vector2 (position.x, Screen.height - position.y);
		Vector2 bloodSize = GUI.skin.label.CalcSize (new GUIContent(blood_red));

		int blood_width = blood_red.width * HP/100;
		GUI.DrawTexture(new Rect(position.x - (bloodSize.x/2),position.y - bloodSize.y ,bloodSize.x,bloodSize.y),blood_black);
		GUI.DrawTexture(new Rect(position.x - (bloodSize.x/2),position.y - bloodSize.y ,blood_width,bloodSize.y),blood_red);
		
		labelText = name + " (剩余 " + HP + " 发)";
		
		Vector2 nameSize = GUI.skin.label.CalcSize (new GUIContent(labelText));
		GUI.color  = Color.white;
		
		GUI.Label(new Rect(position.x - (nameSize.x/2),position.y - nameSize.y - bloodSize.y ,nameSize.x,nameSize.y), labelText);
		//talkBoxText.wrapMode = TextureWrapMode.Clamp;
		//GUI.Box(new Rect(position.x - (nameSize.x/2),position.y - nameSize.y - bloodSize.y ,nameSize.x,nameSize.y),talkBoxText);
		
		//GUI.Box(new Rect(position.x - (nameSize.x/2),position.y - nameSize.y - bloodSize.y ,nameSize.x,nameSize.y), labelText);
		updateInfoString();
		
		GUI.Label(new Rect(10,10,400,20),infoString);
	}

	
	void OnMouseDrag ()
	{
		Debug.Log("MouseDrag");
	}

	void OnMouseDown()
	{
		Debug.Log("MouseDown");

		if(HP >0)
		{
			//HP -=5 ;
		}

	}
	void OnMouseUp()
	{
		Debug.Log("MouseUp");
	}

	void OnMouseEnter()
	{
		Debug.Log("MouseEnter");
	}
	void OnMouseExit()
	{
		Debug.Log("MouseExit");
	}
	void OnMouseOver()
	{
		Debug.Log("MouseOver");
	}

}