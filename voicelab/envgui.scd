(
a = Window("text-boxes", Rect(200 , 450, 450, 450));
a.view.decorator = FlowLayout(a.view.bounds);

b = EnvelopeView(a, Rect(0, 0, 440, 440))
    .thumbWidth_(20.0)
    .thumbHeight_(20.0)
    .drawLines_(false)
    .drawRects_(true)
    .selectionColor_(Color.red)
    .value_([[0.1, 0.4], [0.1, 0.2]]);
2.do({arg i;
    //b.setString(i, ["this", "is", "so much", "fun"].at(i));
    b.setFillColor(i,[Color.white, Color.green].choose);
});
a.front;
)
