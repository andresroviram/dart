import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rfw/rfw.dart';

LocalWidgetLibrary createOnboardingLocalWidgets() {
  return LocalWidgetLibrary(<String, LocalWidgetBuilder>{
    'PhoneNumberField': (BuildContext context, DataSource source) {
      final onChanged = source.handler(
        <Object>['onChanged'],
        (HandlerTrigger trigger) => (String value) {
          trigger(<String, Object?>{'value': value});
        },
      );

      return _PhoneNumberField(
        value: source.v<String>(<Object>['value']) ?? '',
        onChanged: onChanged,
      );
    },
    'SocialIcon': (BuildContext context, DataSource source) {
      return _SocialIcon(kind: source.v<String>(<Object>['kind']) ?? '');
    },
  });
}

class _PhoneNumberField extends StatefulWidget {
  const _PhoneNumberField({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String>? onChanged;

  @override
  State<_PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<_PhoneNumberField> {
  Offset? _outsidePointerDownPosition;

  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void didUpdateWidget(covariant _PhoneNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.phone,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        maxLength: 10,
        onChanged: widget.onChanged,
        onTapOutside: (event) {
          _outsidePointerDownPosition = event.position;
        },
        onTapUpOutside: (event) {
          final pointerDownPosition = _outsidePointerDownPosition;
          _outsidePointerDownPosition = null;
          if (pointerDownPosition == null ||
              (event.position - pointerDownPosition).distance > kTouchSlop) {
            return;
          }
          FocusManager.instance.primaryFocus?.unfocus();
        },
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF242329), fontSize: 14),
        decoration: const InputDecoration(
          counterText: '',
          hintText: 'Tu número telefónico',
          hintStyle: TextStyle(color: Color(0xFFB9B7BC), fontSize: 13),
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(9)),
            borderSide: BorderSide(color: Color(0xFFF0F0F2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(9)),
            borderSide: BorderSide(color: Color(0xFF00A82D), width: 1.2),
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.kind});

  final String kind;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      'google' => SvgPicture.asset(
          'assets/icons/google.svg',
          width: 23,
          height: 24,
        ),
      'face-id' => SvgPicture.asset(
          'assets/icons/face_id.svg',
          width: 24,
          height: 24,
        ),
      'apple' => const Icon(Icons.apple, size: 24, color: Color(0xFF242329)),
      _ => const SizedBox.shrink(),
    };
  }
}
