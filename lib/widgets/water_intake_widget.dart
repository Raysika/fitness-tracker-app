import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';
import 'package:fitness_tracker/services/supabase_service.dart';
import 'package:intl/intl.dart';

class WaterIntakeWidget extends StatefulWidget {
  final int waterIntake;
  final int waterGoal;
  final Function(int) onAddWater;

  const WaterIntakeWidget({
    Key? key,
    required this.waterIntake,
    required this.waterGoal,
    required this.onAddWater,
  }) : super(key: key);

  @override
  State<WaterIntakeWidget> createState() => _WaterIntakeWidgetState();
}

class _WaterIntakeWidgetState extends State<WaterIntakeWidget> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _waterIntakeDetails = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWaterIntakeDetails();
  }

  Future<void> _loadWaterIntakeDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final details = await _supabaseService.getDailyWaterIntakeDetails(today);

      setState(() {
        _waterIntakeDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading water intake details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addWater(int amount) async {
    try {
      await _supabaseService.logWaterIntake(amount);
      widget.onAddWater(amount);
      _loadWaterIntakeDetails();
    } catch (e) {
      print('Error adding water: $e');
    }
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';
    try {
      final dateTime = DateTime.parse(isoTime);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  // Group entries by time period
  Map<String, int> _getGroupedIntakes() {
    Map<String, int> groupedIntakes = {
      '5am - 10am': 0,
      '10am - 1pm': 0,
      '1pm - 4pm': 0,
      '4pm - 7pm': 0,
      '7pm - now': 0,
    };

    for (var entry in _waterIntakeDetails) {
      try {
        final time = DateTime.parse(entry['time']);
        final hour = time.hour;

        if (hour >= 5 && hour < 10) {
          groupedIntakes['5am - 10am'] =
              (groupedIntakes['5am - 10am'] ?? 0) + (entry['amount'] as int);
        } else if (hour >= 10 && hour < 13) {
          groupedIntakes['10am - 1pm'] =
              (groupedIntakes['10am - 1pm'] ?? 0) + (entry['amount'] as int);
        } else if (hour >= 13 && hour < 16) {
          groupedIntakes['1pm - 4pm'] =
              (groupedIntakes['1pm - 4pm'] ?? 0) + (entry['amount'] as int);
        } else if (hour >= 16 && hour < 19) {
          groupedIntakes['4pm - 7pm'] =
              (groupedIntakes['4pm - 7pm'] ?? 0) + (entry['amount'] as int);
        } else if (hour >= 19) {
          groupedIntakes['7pm - now'] =
              (groupedIntakes['7pm - now'] ?? 0) + (entry['amount'] as int);
        }
      } catch (e) {
        print('Error processing water intake entry: $e');
      }
    }

    return groupedIntakes;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress
    final progress = widget.waterIntake / widget.waterGoal;
    final displayProgress = progress > 1.0 ? 1.0 : progress;

    // Format water intake in liters
    final waterIntakeLiters = widget.waterIntake / 1000;

    // Get grouped intakes
    final groupedIntakes = _getGroupedIntakes();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        color: TColor.lightGrayColor(context),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Left side - water progress indicator
          Container(
            width: 20,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 20,
                  height: 180 * displayProgress,
                  decoration: BoxDecoration(
                    color: TColor.primaryColor1.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),

          // Right side - water intake details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Water Intake",
                  style: TextStyle(
                    color: TColor.textColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      "${waterIntakeLiters.toStringAsFixed(1)} Liters",
                      style: TextStyle(
                        color: TColor.primaryColor1,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  "Real time updates",
                  style: TextStyle(
                    color: TColor.grayColor(context),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 10),

                // Time slots
                ...[
                  _buildTimeSlot(
                      context, "5am - 10am", groupedIntakes['5am - 10am'] ?? 0),
                  _buildTimeSlot(
                      context, "10am - 1pm", groupedIntakes['10am - 1pm'] ?? 0),
                  _buildTimeSlot(
                      context, "1pm - 4pm", groupedIntakes['1pm - 4pm'] ?? 0),
                  _buildTimeSlot(
                      context, "4pm - 7pm", groupedIntakes['4pm - 7pm'] ?? 0),
                  _buildTimeSlot(
                      context, "7pm - now", groupedIntakes['7pm - now'] ?? 0),
                ],
              ],
            ),
          ),

          // Add button
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _showAddWaterDialog(context),
                icon: Icon(
                  Icons.add_circle_outline,
                  color: TColor.primaryColor1,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(BuildContext context, String time, int amount) {
    final amountInMl = amount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: TColor.primaryColor1,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            time,
            style: TextStyle(
              color: TColor.grayColor(context),
              fontSize: 12,
            ),
          ),
          Spacer(),
          Text(
            "${amountInMl}ml",
            style: TextStyle(
              color: TColor.textColor(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Quick custom amount chips
  Widget _buildQuickAmountChip(
      BuildContext context, int amount, TextEditingController controller) {
    return GestureDetector(
      onTap: () {
        controller.text = amount.toString();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: TColor.primaryColor1.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: TColor.primaryColor1.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          "$amount ml",
          style: TextStyle(
            color: TColor.primaryColor1,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showAddWaterDialog(BuildContext context) {
    // Controller for custom amount text field
    final TextEditingController customAmountController =
        TextEditingController();
    int? customAmount;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Water",
                    style: TextStyle(
                      color: TColor.textColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Preset options
                  _buildWaterOption(context, 200, "Small Glass (200ml)"),
                  _buildWaterOption(context, 300, "Medium Glass (300ml)"),
                  _buildWaterOption(context, 500, "Large Glass (500ml)"),
                  _buildWaterOption(context, 750, "Water Bottle (750ml)"),

                  // Divider between preset options and custom input
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                        height: 1,
                        color: TColor.grayColor(context).withOpacity(0.3)),
                  ),

                  // Custom amount input
                  Text(
                    "Custom Amount",
                    style: TextStyle(
                      color: TColor.textColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Quick amount suggestions
                  Row(
                    children: [
                      _buildQuickAmountChip(
                          context, 100, customAmountController),
                      _buildQuickAmountChip(
                          context, 250, customAmountController),
                      _buildQuickAmountChip(
                          context, 400, customAmountController),
                      _buildQuickAmountChip(
                          context, 1000, customAmountController),
                    ],
                  ),

                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter amount (ml)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color:
                                    TColor.grayColor(context).withOpacity(0.3),
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            suffixText: "ml",
                          ),
                          onChanged: (value) {
                            customAmount = int.tryParse(value);
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (customAmount != null && customAmount! > 0) {
                            _addWater(customAmount!);
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please enter a valid amount"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primaryColor1,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Add",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: TColor.grayColor(context)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaterOption(BuildContext context, int amount, String label) {
    return ListTile(
      title: Text(label),
      trailing: Text("${amount}ml"),
      onTap: () {
        _addWater(amount);
        Navigator.pop(context);
      },
    );
  }
}
