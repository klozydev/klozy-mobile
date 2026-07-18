import 'package:equatable/equatable.dart';

enum TrackStepState { done, active, pending }

class TrackingStep extends Equatable {
  final String label;
  final String? sublabel;
  final TrackStepState state;

  const TrackingStep({
    required this.label,
    this.sublabel,
    this.state = TrackStepState.pending,
  });

  @override
  List<Object?> get props => [label, sublabel, state];
}

class OrderTracking extends Equatable {
  final String carrier;
  final String? trackingNumber;
  final String? liveTrackingUrl;
  final String? labelUrl;

  /// Return shipment tracking number (`tracking.returnTrackingNumber`).
  /// Visible to both buyer and seller.
  final String? returnTrackingNumber;

  /// Return shipping label (`tracking.returnLabelUrl`). Buyer-only; the API
  /// omits it for the seller.
  final String? returnLabelUrl;
  final List<TrackingStep> steps;

  const OrderTracking({
    this.carrier = 'EMX',
    this.trackingNumber,
    this.liveTrackingUrl,
    this.labelUrl,
    this.returnTrackingNumber,
    this.returnLabelUrl,
    this.steps = const <TrackingStep>[],
  });

  @override
  List<Object?> get props => [
    carrier,
    trackingNumber,
    liveTrackingUrl,
    labelUrl,
    returnTrackingNumber,
    returnLabelUrl,
    steps,
  ];
}
