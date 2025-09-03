class AccountCategory {
  final int? id;
  final String name;
  final String icon;
  final bool isExpense;

  AccountCategory({
    this.id,
    required this.name,
    required this.icon,
    required this.isExpense,
  });

  static AccountCategory fromMap(Map<String, dynamic> map) {
    return AccountCategory(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      isExpense: map['is_expense'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'is_expense': isExpense ? 1 : 0,
    };
  }
}

List<AccountCategory> defaultAccountCategories = [
  AccountCategory(id: 1, name: '餐饮', icon: 'restaurant', isExpense: true),
  AccountCategory(id: 2, name: '交通', icon: 'directions_car', isExpense: true),
  AccountCategory(id: 3, name: '购物', icon: 'shopping_cart', isExpense: true),
  AccountCategory(id: 4, name: '住房', icon: 'home', isExpense: true),
  AccountCategory(id: 5, name: '娱乐', icon: 'movie', isExpense: true),
  AccountCategory(id: 6, name: '医疗', icon: 'local_hospital', isExpense: true),
  AccountCategory(id: 7, name: '教育', icon: 'school', isExpense: true),
  AccountCategory(id: 8, name: '其他支出', icon: 'more_horiz', isExpense: true),
  AccountCategory(id: 101, name: '工资', icon: 'work', isExpense: false),
  AccountCategory(id: 102, name: '奖金', icon: 'card_giftcard', isExpense: false),
  AccountCategory(id: 103, name: '投资收益', icon: 'trending_up', isExpense: false),
  AccountCategory(id: 104, name: '其他收入', icon: 'more_horiz', isExpense: false),
];
