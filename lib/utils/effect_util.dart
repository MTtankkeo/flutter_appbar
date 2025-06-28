class EffectUtil {
  static double invertInRange(double value, double start, double end) {
    double minValue = start < end ? start : end;
    double maxValue = start < end ? end : start;

    if (value <= minValue) return 0;
    if (value >= maxValue) return 1;

    double normalized = (value - minValue) / (maxValue - minValue);
    return normalized;
  }
}
