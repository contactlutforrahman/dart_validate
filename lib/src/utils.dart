
part of dart_validate;

/// Helper to get the runtime-Info.
class instanceCheck<T> {
    final bool _strict;

    /// if strict is set to true List<String> == List comparison return false
    instanceCheck({final bool strict: true }) : _strict = strict;

    bool check(final obj) {
        return (obj is T && _strict == false) || (_strict == true && obj is T && obj.runtimeType.toString() == type);
    }

    String get type {
        final String type = this.runtimeType.toString().replaceFirst(new RegExp(r'[^<]+<'),'').replaceFirst(new RegExp(r'>$'),'');
        //print("T $type");
        return type;
    }
}

