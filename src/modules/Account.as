package modules {
	import flash.display.*;
    import flash.events.*;
    import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import flash.ui.Mouse;

	import modules.BaseScreen;
	import services.DataManager;
	import services.SoundManager;
	
	public class Account extends BaseScreen {

		public var userComponent: MovieClip;
		public var addUserBtn: SimpleButton;
		public var overlay: MovieClip;
		public var userAddCover: MovieClip;
		public var title: TextField;
		public var alertText:TextField;
		public var noBtn: SimpleButton;
		public var yesBtn: SimpleButton;
		public var userInput: TextField;

		private var userItem:Array = [];
		private var deleteUserAccept:Boolean = false;
		private var selectedItem:AccountComponent;
		private var editingUser:Object = null;
		private var alertTimer:Timer;

		public function Account() {
			super();

			addEventListener(Event.ADDED_TO_STAGE, init);

			trace("Account.as loaded");
		}

		private function init(e: Event): void  {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			removeUserComponent();
			initUserModal();
			intiDeleteModal();
			initAlert();
			userPanel();
			buildAccount();
		}

		// Remove the user component in first frame of the account panel to avoid duplication
		private function removeUserComponent():void {
			var userComponentHide:MovieClip = getChildByName("user_component") as MovieClip;

			if (userComponentHide) {
				removeChild(userComponentHide)
			}
		}

		private function userPanel():void {
			initUsersPanel();

			if (addUserBtn) {
                addUserBtn.addEventListener(MouseEvent.CLICK, onAddUserClick);
            } 
		}

		private function initUsersPanel(): void {
			addUserBtn = getChildByName("add_user_btn") as SimpleButton;
			
			registerTooltips(addUserBtn, "Add User");
		}

		private function userModal(e: MouseEvent = null): void {
			initUserModal();
			showUserModal();
			userModalAction();
		}

		private function deleteModal(e: MouseEvent = null): void {
			intiDeleteModal();
			showDeleteModal();
			deleteModalAction();
		}

		private function userModalAction():void {
			if (noBtn) {
				noBtn.removeEventListener(MouseEvent.CLICK, userModalNoBtn);
				noBtn.addEventListener(MouseEvent.CLICK, userModalNoBtn);
            }

            if (yesBtn) {
                yesBtn.removeEventListener(MouseEvent.CLICK, showResult);
                yesBtn.addEventListener(MouseEvent.CLICK, showResult);
            } 
		}

		private function deleteModalAction():void {
			if (noBtn) {
				noBtn.removeEventListener(MouseEvent.CLICK, deleteModalNoBtn);
				noBtn.addEventListener(MouseEvent.CLICK, deleteModalNoBtn);
            }

            if (yesBtn) {
                yesBtn.removeEventListener(MouseEvent.CLICK, deleteUserAction);
                yesBtn.addEventListener(MouseEvent.CLICK, deleteUserAction)
            } 
		}

		// Modal button actions
		private function userModalNoBtn(e:MouseEvent = null):void {
			playSoundEffect();
			hideUserModal();
		}

		// Modal button actions
		private function deleteModalNoBtn(e:MouseEvent = null):void {
			playSoundEffect();
			hideDeleteModal();

		}

		private function alertAction(msg:String, w: Number, y: Number, x: Number): void {
			alertStyle(w, y, x);
			
			alertText.text = "";
			alertText.text = msg;

			showAlert();
		}

		private function alertStyle(w: Number, y: Number, x: Number):void {

			alertText.autoSize = TextFieldAutoSize.CENTER;

    		alertText.background = true;
    		alertText.backgroundColor = 0xBB0202;

			alertText.width = w;
			alertText.y = y;
			alertText.x = x;

			bringToFront(alertText);
		}

		private function initUserModal():void {
			overlay = getChildByName("user_modal_overlay") as MovieClip;
			userAddCover = getChildByName("user_modal_cover") as MovieClip;
			title = getChildByName("user_modal_title") as TextField;
            userInput = getChildByName("user_modal_input") as TextField;
            noBtn = getChildByName("user_modal_no_btn") as SimpleButton;
            yesBtn = getChildByName("user_modal_yes_btn") as SimpleButton;

			hideUserModal();
		}

		private function intiDeleteModal():void {
			overlay = getChildByName("delete_modal_overlay") as MovieClip;
			userAddCover = getChildByName("delete_modal_cover") as MovieClip;
			title = getChildByName("delete_modal_title") as TextField;
            noBtn = getChildByName("delete_modal_no_btn") as SimpleButton;
            yesBtn = getChildByName("delete_modal_yes_btn") as SimpleButton;

			hideDeleteModal();
		}

		private function initAlert():void {
			alertText = getChildByName("alert_text") as TextField;

			hideAlert();
		}

		private function showUserModal(e:MouseEvent = null): void {
			if (overlay) {
				overlay.visible = true;
				userAddCover.visible = true;
				title.visible = true;
				userInput.visible = true;
				noBtn.visible = true;
				yesBtn.visible = true;

				bringToFront(overlay);
				bringToFront(userAddCover);
				bringToFront(title);
				bringToFront(userInput);
				bringToFront(noBtn);
				bringToFront(yesBtn);
			}
		}

		private function showDeleteModal(e:MouseEvent = null):void {
			if (overlay) {
				overlay.visible = true;
				userAddCover.visible = true;
				title.visible = true;
				noBtn.visible = true;
				yesBtn.visible = true;

				bringToFront(overlay);
				bringToFront(userAddCover);
				bringToFront(title);
				bringToFront(noBtn);
				bringToFront(yesBtn);
			}
		}

		private function showAlert(e:MouseEvent = null):void {
			if (!alertText) return;
		
			alertText.visible = true;
			
	
			if (alertTimer) {
				alertTimer.stop();
				alertTimer.reset();
			} else {
				alertTimer = new Timer(4000, 1);
				alertTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onAlertTimerComplete);
			}

			alertTimer.start();
		} 

		private function onAlertTimerComplete(e:TimerEvent):void {
			hideAlert();
		}

		private function hideUserModal(e:MouseEvent = null): void {
			if (overlay) {
				overlay.visible = false;
				userAddCover.visible = false;
				title.visible = false;
				userInput.visible = false;
				noBtn.visible = false;
				yesBtn.visible = false;
			}
				
			if (userInput) {
				userInput.text = "";
			}
		}

		private function hideDeleteModal(e: MouseEvent = null):void {
			if (overlay) {
				overlay.visible = false;
				userAddCover.visible = false;
				title.visible = false;
				noBtn.visible = false;
				yesBtn.visible = false;
			}
		}

		private function hideAlert(e:MouseEvent = null):void {
				alertText.visible = false;

		} 

		private function showResult(e: MouseEvent): void {
			playSoundEffect();

			if (!userInput) return;

			var inputText: String = userInput.text;

			if (inputText == "") {
				var text: String = "Username cannot be blank.";
				alertAction(text, 267.95, 70, 73.55);
				return;
			} 

			if (editingUser) {
				DataManager.getInstance().updateUserName(editingUser.id, inputText);

				editingUser = null;

				trace("User Updated");

			} else {

				var newUser:Object = {
					id: new Date().time.toString(),
					name: inputText,
					highScore: 0
				}

				DataManager.getInstance().addUser(newUser);				
			}

			userInput.text = "";
			hideUserModal();
			refreshUsers();
		}

		// Function to refresh the user list and rebuild the account panel
		private function refreshUsers():void {
			playSoundEffect();

			for each (var item:AccountComponent in userItem) {
				if (contains(item)) removeChild(item);
			}

			userItem = [];
			buildAccount();
		}

		private function buildAccount():void {
			var users:Array = DataManager.getInstance().getUsers();

			if (!users) {
				trace("No users loaded");
				return;
			}

			var activeId:String = DataManager.getInstance().currentUserId;

			if (activeId == null && users.length > 0) {
				activeId = users[0].id;
				DataManager.getInstance().setCurrentUserId(activeId);
			}

			var yPos:int = 233;
			var xPos:int = 209;

			for (var i:int = 0; i < users.length; i++) {
				var user:Object = users[i];

				var item:AccountComponent = new AccountComponent();

				item.user_name.text = user.name;

				item.y = yPos;
				item.x = xPos;

				yPos += 75;

				if (user.id == activeId) {
					item.tick.visible = true;
					item.overlay_active.visible = false;

					item.edit_user_name_btn.removeEventListener(MouseEvent.CLICK, onEditUserClick);
					item.remove_user_btn.removeEventListener(MouseEvent.CLICK, onDeleteUserRequest);
			
					item.edit_user_name_btn.addEventListener(MouseEvent.CLICK, onEditUserClick);
					item.remove_user_btn.addEventListener(MouseEvent.CLICK, onDeleteUserRequest);

					// Bring the edit and remove buttons to the front of the display list
					item.setChildIndex(item.edit_user_name_btn, item.numChildren - 1);
					item.setChildIndex(item.remove_user_btn, item.numChildren - 1);

					registerTooltips(item.edit_user_name_btn, "Edit User Name");
					registerTooltips(item.remove_user_btn, "Remove User");

				} else {
					item.tick.visible = false;
					item.overlay_active.visible = false;

					item.buttonMode = true;
					item.useHandCursor = true;

					item.addEventListener(MouseEvent.ROLL_OVER, onUserOver);
					item.addEventListener(MouseEvent.ROLL_OUT, onUserOut);
					item.addEventListener(MouseEvent.CLICK, onSelectUser);
				}

				item.userData = user;

				userItem.push(item);
				addChild(item);
			}
		}

		private function onUserOver(e:MouseEvent):void {
    		var item:AccountComponent = e.currentTarget as AccountComponent;

			if (item.userData.id != DataManager.getInstance().currentUserId) {
    			item.overlay_active.visible = true;	
			}
		}

		private function onUserOut(e:MouseEvent):void {
    		var item:AccountComponent = e.currentTarget as AccountComponent;

			if (item.userData.id != DataManager.getInstance().currentUserId) {
					item.overlay_active.visible = false;
			}
		}

		private function onSelectUser(e:MouseEvent):void {
			var item:AccountComponent = e.currentTarget as AccountComponent;
	
			DataManager.getInstance().setCurrentUserId(item.userData.id);
	
			refreshUsers();
		}

		// Function to bring a display object to the front of the display list
		private function bringToFront(target:DisplayObject):void {
			if (target && contains(target)) {
				setChildIndex(target, numChildren - 1);
			}
		}

		private function onAddUserClick(e:MouseEvent):void {
			playSoundEffect();

    		editingUser = null;
    		userInput.text = "";

    		userModal();
		}

		private function onEditUserClick(e:MouseEvent):void {
			playSoundEffect();

			var item:AccountComponent = e.currentTarget.parent as AccountComponent;

			var user:Object = item.userData;
			
			editingUser = user;

			userModal();

			userInput.text = user.name;

		}

		private function deleteUserAction(e:MouseEvent):void {
			playSoundEffect();

			if (!selectedItem) return;

				var dm:DataManager = DataManager.getInstance();
				var user:Object = selectedItem.userData;

				var wasActive:Boolean = (user.id == dm.currentUserId);

				removeChild(selectedItem);

				var index:int = userItem.indexOf(selectedItem);
				if (index != -1) {
					userItem.splice(index, 1);
				}

				dm.removeUser(user.id);

				if (wasActive) {
					if (userItem.length > 0) {
						dm.setCurrentUserId(userItem[0].userData.id);
					} else {
						dm.setCurrentUserId(null);
					}
				}

				refreshUsers();

				layoutUsers();

				hideDeleteModal();

				selectedItem = null;
		}

		// Handle the delete user request when the remove button is clicked
		private function onDeleteUserRequest(e:MouseEvent):void {
			playSoundEffect();

			if (userItem.length <= 1) {
				var text:String = "You cannot delete the only user account. Please add a new user first, then you can delete this one."
				alertAction(text, 330, 30, 42.55);
				return;
			}

			selectedItem = e.currentTarget.parent as AccountComponent;

			deleteModal();
		}

		// Layout the user items in the account panel after a user is deleted
		private function layoutUsers():void {
			var yPos:int = 233;
			var xPos:int = 209;

			for (var i:int = 0; i < userItem.length; i++) {
				var item:AccountComponent = userItem[i];

				item.x = xPos;
				item.y = yPos;

				yPos += 75;
			}
		}

		private function playSoundEffect(): void {
			SoundManager.getInstance().mouseClickEffect();
		}
	}
}