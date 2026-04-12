import 'package:admin_control/core/routes/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/coupon_model.dart';
import '../providers/coupon_provider.dart';

class AddEditCouponScreen extends StatefulWidget {
  final CouponModel? coupon;

  const AddEditCouponScreen({super.key, this.coupon});

  @override
  State<AddEditCouponScreen> createState() => _AddEditCouponScreenState();
}

class _AddEditCouponScreenState extends State<AddEditCouponScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _code;
  late TextEditingController _discountValue;
  late TextEditingController _maxDiscount;
  late TextEditingController _minOrder;

  CouponType _type = CouponType.percentage;
  DateTime? _expiryDate;
  bool _isActive = true;
  bool _isLoading = false;

  bool get isEdit => widget.coupon != null;

  @override
  void initState() {
    super.initState();

    final c = widget.coupon;

    _code = TextEditingController(text: c?.code ?? '');
    _discountValue =
        TextEditingController(text: c?.discountValue.toString() ?? '');
    _maxDiscount =
        TextEditingController(text: c?.maxDiscount.toString() ?? '');
    _minOrder =
        TextEditingController(text: c?.minOrderAmount.toString() ?? '');

    _type = c?.discountType ?? CouponType.percentage;
    _expiryDate = c?.expiryDate;
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _code.dispose();
    _discountValue.dispose();
    _maxDiscount.dispose();
    _minOrder.dispose();
    super.dispose();
  }

  // =========================
  // 📅 PICK DATE
  // =========================
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  // =========================
  // 🚀 SAVE
  // =========================
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_expiryDate == null) {
      _snack("Select expiry date");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final coupon = CouponModel(
        id: widget.coupon?.id ?? '',
        code: _code.text.trim().toUpperCase(),
        discountType: _type,
        discountValue: double.parse(_discountValue.text),
        maxDiscount: double.tryParse(_maxDiscount.text) ?? 0,
        minOrderAmount: double.parse(_minOrder.text),
        expiryDate: _expiryDate!,
        isActive: _isActive,
        createdAt: widget.coupon?.createdAt ?? DateTime.now(),
      );

      final provider = context.read<CouponProvider>();

      if (isEdit) {
        await provider.addCoupon(coupon); // 🔁 replace with update if available
      } else {
        await provider.addCoupon(coupon);
      }

      if (!mounted) return;

      _snack("Coupon saved");
      NavigationService.goBack();
    } catch (e) {
      _snack("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // =========================
  // 🧱 UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(isEdit ? "Edit Coupon" : "Add Coupon"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_code, "Coupon Code"),

              const SizedBox(height: 12),

              /// TYPE
              DropdownButtonFormField<CouponType>(
                value: _type,
                items: CouponType.values.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _type = v!),
                decoration: const InputDecoration(
                  labelText: "Discount Type",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              _field(_discountValue, "Discount Value", isNumber: true),

              const SizedBox(height: 12),

              _field(_maxDiscount, "Max Discount (Optional)", isNumber: true),

              const SizedBox(height: 12),

              _field(_minOrder, "Min Order Amount", isNumber: true),

              const SizedBox(height: 12),

              /// DATE
              ListTile(
                title: Text(
                  _expiryDate == null
                      ? "Select Expiry Date"
                      : _expiryDate.toString().substring(0, 10),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text("Active"),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(isEdit ? "Update Coupon" : "Add Coupon"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: c,
      keyboardType:
          isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return "Enter $label";
        if (isNumber && double.tryParse(v) == null) {
          return "Enter valid number";
        }
        return null;
      },
    );
  }
}