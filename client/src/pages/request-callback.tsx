import { useState } from "react";
import { useLocation } from "wouter";
import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Phone, Clock, CheckCircle2 } from "lucide-react";
import { toast } from "@/hooks/use-toast";

export default function RequestCallbackPage() {
  const [, setLocation] = useLocation();
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);
    toast({
      title: "Request Sent",
      description: "A verified agent will call you within 15 minutes.",
    });
  };

  if (submitted) {
    return (
      <div className="container mx-auto px-4 py-20 text-center max-w-md">
        <div className="w-20 h-20 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto mb-6">
          <CheckCircle2 className="w-10 h-10" />
        </div>
        <h2 className="text-2xl font-bold mb-2">Request Received!</h2>
        <p className="text-slate-500 mb-8">Our team is reviewing your request. Expect a call shortly.</p>
        <Button onClick={() => setLocation("/")} variant="outline" className="w-full">Return Home</Button>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-12 max-w-2xl">
      <Card className="shadow-2xl border-slate-200">
        <CardHeader className="text-center">
          <div className="w-12 h-12 bg-blue-600 text-white rounded-xl flex items-center justify-center mx-auto mb-4">
            <Phone className="w-6 h-6" />
          </div>
          <CardTitle className="text-3xl font-display font-bold">Request a Callback</CardTitle>
          <CardDescription>Get professional advice from our verified real estate experts.</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="name">Full Name</Label>
                <Input id="name" placeholder="John Doe" required />
              </div>
              <div className="space-y-2">
                <Label htmlFor="phone">Phone Number</Label>
                <Input id="phone" placeholder="+234..." required />
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="time">Preferred Time</Label>
              <div className="grid grid-cols-2 gap-2">
                {["As soon as possible", "Morning (9am - 12pm)", "Afternoon (12pm - 4pm)", "Evening (4pm - 7pm)"].map(time => (
                  <Button key={time} type="button" variant="outline" className="justify-start font-normal text-xs h-10 px-3 hover:bg-blue-50 hover:border-blue-200 transition-colors">
                    <Clock className="w-3 h-3 mr-2" />
                    {time}
                  </Button>
                ))}
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="notes">How can we help?</Label>
              <Textarea id="notes" placeholder="I'm interested in the property at..." className="min-h-[100px]" />
            </div>
            <Button type="submit" className="w-full bg-blue-600 hover:bg-blue-700 h-12 text-lg">Send Request</Button>
          </form>
        </CardContent>
        <CardFooter className="bg-slate-50 justify-center py-4 border-t">
          <p className="text-xs text-slate-500">Average response time: 12 minutes</p>
        </CardFooter>
      </Card>
    </div>
  );
}
