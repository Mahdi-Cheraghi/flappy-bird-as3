package modules {
	import flash.display.*;
	import flash.events.*;

	import modules.BaseScreen;
	import services.DataManager;

	public class Ranking extends BaseScreen {

		public function Ranking() {
			super();

			addEventListener(Event.ADDED_TO_STAGE, init);

            trace("Ranking.as loaded");
		}

		private function init(e: Event): void {
			removeEventListener(Event.ADDED_TO_STAGE, init);

			var rankingComponentHide: MovieClip = getChildByName("ranking_component_in_edit") as MovieClip;
			rankingComponentHide.visible = false;

			buildRanking();
		}

		private function buildRanking():void {
			var users:Array = DataManager.getInstance().getUsers().slice();

			if (!users) {
				trace("No users loaded");
				return;
			}

			// Sort users by high score in descending order
			users.sort(function(a: Object, b: Object): Number {
				return b.highScore - a.highScore;
			})

			var yPos:int = 233;
			var xPos:int = 209;

			for (var i:int = 0; i < users.length; i++) {
				var user:Object = users[i];

				var item:RankingComponent = new RankingComponent();

				item.player_rank.text = String(i + 1);
				item.player_name.text = user.name;
				item.player_score.text = String(user.highScore);

				item.y = yPos;
				item.x = xPos;

				yPos += 75;

				addChild(item);
			}
		}
	}
}  