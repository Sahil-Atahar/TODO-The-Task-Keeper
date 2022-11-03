class TODOItem {
  static int id = 0;
  static String itemName = '';
  static int color = 0;
  static String isCompleted = '';

  TODOItem(Map<String, dynamic> todoItem) {
    id = todoItem['id'];
    itemName = todoItem['itemName'];
    color = todoItem['color'];
    isCompleted = todoItem['isCompleted'];
  }
}
