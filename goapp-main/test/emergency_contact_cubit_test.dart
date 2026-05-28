import "package:flutter_test/flutter_test.dart";
import "package:goapp/features/activity/presentation/cubit/emergency_contacts_cubit.dart";

void main() {
  group("EmergencyContactsCubit", () {
    test("starts with a single primary contact sorted first", () {
      final cubit = EmergencyContactsCubit();
      expect(cubit.state.contacts, isNotEmpty);
      expect(cubit.state.contacts.first.isPrimary, isTrue);
    });

    test("adds a contact and keeps sort order", () {
      final cubit = EmergencyContactsCubit();
      cubit.addContact(
        const EmergencyContact(
          name: "Aaron Smith",
          number: "+1 111111111",
          isPrimary: false,
        ),
      );
      expect(cubit.state.contacts.any((c) => c.name == "Aaron Smith"), isTrue);
      expect(cubit.state.contacts.first.isPrimary, isTrue);
    });

    test("sets selected contact as primary", () {
      final cubit = EmergencyContactsCubit();
      cubit.makePrimary(1);
      final primaryCount = cubit.state.contacts
          .where((c) => c.isPrimary)
          .length;
      expect(primaryCount, 1);
      expect(cubit.state.contacts.first.isPrimary, isTrue);
    });

    test("deletes contact by index", () {
      final cubit = EmergencyContactsCubit();
      final initialLength = cubit.state.contacts.length;
      cubit.deleteContact(0);
      expect(cubit.state.contacts.length, initialLength - 1);
    });

    test("validates contact input", () {
      final valid = EmergencyContactsCubit.isValidContactInput(
        name: "John",
        number: "12345",
      );
      final invalid = EmergencyContactsCubit.isValidContactInput(
        name: "  ",
        number: "12345",
      );
      expect(valid, isTrue);
      expect(invalid, isFalse);
    });
  });
}
